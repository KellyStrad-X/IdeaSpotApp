/**
 * Firebase Cloud Function for IdeaSpot
 *
 * This function receives a voice transcript and uses Claude AI to expand it
 * into a structured idea with title and multiple expansion sections.
 *
 * Deploy with:
 *   cd functions
 *   npm install firebase-functions@latest firebase-admin@latest @anthropic-ai/sdk
 *   firebase deploy --only functions
 *   firebase functions:config:set anthropic.key="your-api-key-here"
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const Anthropic = require('@anthropic-ai/sdk');

admin.initializeApp();

exports.expandIdea = functions.https.onCall(async (data, context) => {
  // Ensure user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to expand ideas'
    );
  }

  const { transcript } = data;

  // Validate input
  if (!transcript || typeof transcript !== 'string' || transcript.trim().length === 0) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Transcript is required and must be a non-empty string'
    );
  }

  if (transcript.length > 5000) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Transcript is too long (max 5000 characters)'
    );
  }

  try {
    // Initialize Anthropic client
    const anthropic = new Anthropic({
      apiKey: functions.config().anthropic.key,
    });

    // Construct the prompt
    const prompt = `You are an AI assistant that helps expand on creative ideas. Given the following voice transcript of an idea, provide:

1. A concise, compelling title (5-10 words max)
2. 3-5 expansion sections with titles and detailed content that help develop the idea

Each expansion section should provide a different perspective:
- Problem Statement: What problem does this solve?
- Solution Overview: How does this idea work?
- Key Features: What are the main components?
- Target Audience: Who would use/benefit from this?
- Next Steps: What would need to happen to move forward?

Choose the 3-5 most relevant sections based on the idea.

Format your response as VALID JSON (no markdown, no code blocks):
{
  "title": "Brief Title Here",
  "expansions": [
    {
      "sectionTitle": "Problem Statement",
      "content": "Detailed content explaining the problem this idea addresses..."
    },
    {
      "sectionTitle": "Solution Overview",
      "content": "Detailed content explaining how this idea works..."
    }
  ]
}

Voice Transcript: "${transcript}"

Respond with ONLY the JSON object, no other text.`;

    // Call Claude API
    const message = await anthropic.messages.create({
      model: 'claude-3-5-sonnet-20241022',
      max_tokens: 2048,
      temperature: 0.7,
      messages: [{
        role: 'user',
        content: prompt
      }]
    });

    // Extract and parse response
    const content = message.content[0].text;

    // Remove any markdown code blocks if present
    const cleanedContent = content.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();

    let result;
    try {
      result = JSON.parse(cleanedContent);
    } catch (parseError) {
      console.error('Failed to parse Claude response:', cleanedContent);
      throw new Error('Invalid JSON response from AI');
    }

    // Validate response structure
    if (!result.title || !Array.isArray(result.expansions)) {
      throw new Error('Invalid response structure from AI');
    }

    // Validate expansions
    for (const expansion of result.expansions) {
      if (!expansion.sectionTitle || !expansion.content) {
        throw new Error('Invalid expansion structure in AI response');
      }
    }

    // Log usage for analytics
    console.log(`Idea expanded for user ${context.auth.uid}`, {
      transcriptLength: transcript.length,
      expansionCount: result.expansions.length,
      tokensUsed: message.usage.input_tokens + message.usage.output_tokens
    });

    // Return the structured result
    return {
      title: result.title,
      expansions: result.expansions,
      metadata: {
        processedAt: admin.firestore.Timestamp.now(),
        model: 'claude-3-5-sonnet-20241022',
        tokensUsed: message.usage.input_tokens + message.usage.output_tokens
      }
    };

  } catch (error) {
    console.error('Error expanding idea:', error);

    // Handle specific error types
    if (error.status === 429) {
      throw new functions.https.HttpsError(
        'resource-exhausted',
        'Too many requests. Please try again later.'
      );
    }

    if (error.status === 401) {
      throw new functions.https.HttpsError(
        'internal',
        'API authentication failed. Please contact support.'
      );
    }

    throw new functions.https.HttpsError(
      'internal',
      'Failed to expand idea. Please try again.'
    );
  }
});

/**
 * Optional: Function to save expanded ideas to Firestore
 * Uncomment if you want server-side backup of ideas
 */
/*
exports.saveExpandedIdea = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { idea } = data;

  await admin.firestore()
    .collection('users')
    .doc(context.auth.uid)
    .collection('ideas')
    .add({
      ...idea,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      userId: context.auth.uid
    });

  return { success: true };
});
*/
