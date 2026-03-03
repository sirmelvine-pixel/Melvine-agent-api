const express = require('express');
const cors = require('cors');
const Anthropic = require('@anthropic-ai/sdk');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

// ── CHAT ENDPOINT ──────────────────────────────────────────
app.post('/chat', async (req, res) => {
  try {
    const { system, messages, max_tokens } = req.body;
    const response = await client.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: max_tokens || 600,
      system,
      messages,
    });
    res.json({ content: response.content });
  } catch (err) {
    console.error('Claude error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// ── HEALTH CHECK ──────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({ status: 'ok', agent: "Bill's AI Agent API" });
});

app.listen(PORT, () => console.log(`Agent API running on port ${PORT}`));
