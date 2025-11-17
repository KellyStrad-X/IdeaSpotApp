const {setGlobalOptions} = require("firebase-functions");
const {onCall} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const Anthropic = require("@anthropic-ai/sdk");

// For cost control, limit max instances
setGlobalOptions({maxInstances: 10});

// Define the secret
const anthropicApiKey = defineSecret("ANTHROPIC_API_KEY");

/**
 * Cloud Function to expand an idea using Claude AI
 * Input: { transcript: string }
 * Output: { title: string, expansions: Array<{...}> }
 */
exports.expandIdea = onCall({secrets: [anthropicApiKey]}, async (request) => {
  const {transcript} = request.data;

  // Initialize Anthropic client with the secret value
  const anthropic = new Anthropic({
    apiKey: anthropicApiKey.value(),
  });

  // Validate input
  if (!transcript || typeof transcript !== "string") {
    throw new Error("Invalid transcript provided");
  }

  logger.info("Processing idea expansion", {transcript});

  try {
    // Define the sections we want Claude to generate
    const sections = [
      {
        key: "problemPainPoint",
        title: "Problem/Pain Point",
        prompt: "What specific problem does this solve? " +
          "Be concrete and identify the core issue.",
      },
      {
        key: "targetCustomer",
        title: "Target Customer",
        prompt: "Who is the target customer? Describe their " +
          "demographics, behaviors, and needs.",
      },
      {
        key: "marketSize",
        title: "Market Size/Opportunity",
        prompt: "What is the market size? Provide estimates " +
          "and market context.",
      },
      {
        key: "validationPlan",
        title: "Validation Plan",
        prompt: "How can this be validated? Suggest concrete " +
          "steps to test demand.",
      },
      {
        key: "firstSteps",
        title: "First Steps",
        prompt: "What are the first steps to get started? " +
          "Provide actionable steps.",
      },
      {
        key: "nameOptions",
        title: "Name Options",
        prompt: "Generate 5 potential names for this idea. " +
          "Make them memorable, professional, and creative. " +
          "Format as a bulleted list.",
      },
    ];

    // Build the prompt for Claude
    const prompt = `You are a business analyst helping an ` +
      `entrepreneur develop their business idea.

Idea Transcript: "${transcript}"

Please analyze this idea and provide structured insights ` +
      `for the following sections:

${sections.map((s, i) => `${i + 1}. ${s.title}: ${s.prompt}`).join("\n\n")}

IMPORTANT: Respond ONLY with a valid JSON object ` +
      `in this exact format:
{
  "title": "Use the first/best name from the nameOptions section",
  "sections": {
    "problemPainPoint": "Your analysis here...",
    "targetCustomer": "Your analysis here...",
    "marketSize": "Your analysis here...",
    "validationPlan": "Your analysis here...",
    "firstSteps": "Your analysis here...",
    "nameOptions": "• Name Option 1\\n• Name Option 2\\n` +
      `• Name Option 3\\n• Name Option 4\\n• Name Option 5"
  }
}

FORMAT REQUIREMENTS:
• Each section should be CONCISE but detailed
• Use 1-2 brief intro sentences followed by bullet points
• Keep bullets short and scannable (1 line each)
• Focus on actionable, specific insights
• Do not write long paragraphs
• Do not include any text outside the JSON object.`;

    // Call Claude API
    const message = await anthropic.messages.create({
      model: "claude-sonnet-4-5-20250929",
      max_tokens: 4096,
      messages: [{
        role: "user",
        content: prompt,
      }],
    });

    // Extract the response
    const responseText = message.content[0].text;
    logger.info("Received response from Claude", {responseText});

    // Strip markdown code blocks if present
    let cleanedText = responseText.trim();
    if (cleanedText.startsWith("```json")) {
      cleanedText = cleanedText
          .replace(/^```json\s*/, "")
          .replace(/```\s*$/, "");
    } else if (cleanedText.startsWith("```")) {
      cleanedText = cleanedText
          .replace(/^```\s*/, "")
          .replace(/```\s*$/, "");
    }

    // Parse JSON response
    let parsedResponse;
    try {
      parsedResponse = JSON.parse(cleanedText);
    } catch (parseError) {
      logger.error("Failed to parse Claude response as JSON",
          {responseText, cleanedText, error: parseError});
      throw new Error("Failed to parse AI response");
    }

    // Transform the response to match the expected format
    const expansions = sections.map((section) => ({
      sectionTitle: section.title,
      content: parsedResponse.sections[section.key] || "Content not generated",
    }));

    const result = {
      title: parsedResponse.title || "Untitled Idea",
      expansions: expansions,
    };

    logger.info("Successfully processed idea expansion", {result});
    return result;
  } catch (error) {
    logger.error("Error expanding idea", {error: error.message});
    throw new Error(`Failed to expand idea: ${error.message}`);
  }
});
