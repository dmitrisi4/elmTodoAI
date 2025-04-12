const express = require('express');
const cors = require('cors');
const axios = require('axios');

const MODEL = 'models/gemini-2.0-pro-exp-02-05';

require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// 🔐 Gemini API key
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

app.post('/api/ai-todos', async (req, res) => {
	const userTask = req.body.task;

	console.log('Получен запрос:', userTask);

	const prompt = `
Break the following task down into specific steps as a JSON array of strings. Example response format:

{
  "steps": [
    "Take step 1",
    "Take step 2"
  ]
}

Задача: ${userTask}
`;

	try {
		const response = await axios.post(
			`https://generativelanguage.googleapis.com/v1beta/${MODEL}:generateContent?key=${GEMINI_API_KEY}`,
			{
				contents: [
					{
						parts: [{text: prompt}]
					}
				]
			}
		);

		// ✨ Response Gemini
		let rawText = response.data.candidates?.[0]?.content?.parts?.[0]?.text || '';

		// Remove markdown formatting ```json ... ```
		rawText = rawText.trim();
		if (rawText.startsWith('```json')) {
			rawText = rawText.replace(/^```json\s*/, '').replace(/```$/, '').trim();
		}

		// Parse JSON
		let parsed;
		try {
			parsed = JSON.parse(rawText);
		} catch (e) {
			console.error('❌ Failed to parse JSON from Gemini:', rawText);
			return res.status(500).json({ error: 'Failed to parse AI response as JSON.' });
		}

		res.json({steps: parsed.steps});
	} catch (err) {
		console.error('error from Gemini:', err?.response?.data || err.message);
		res.status(500).json({error: 'AI generation failed'});
	}
});

app.listen(3000, () => console.log('🚀 Server started: http://localhost:3000'));