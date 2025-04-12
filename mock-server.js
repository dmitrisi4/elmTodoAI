const express = require('express');
const cors = require('cors');
const app = express();
app.use(cors());

app.use(express.json());


app.post('/api/ai-todos', (req, res) => {
	console.log('Запрос:', req.body.task);
	res.json({
		steps: [
			'Купить муку 2',
			'Купить сыр',
			'Замесить тесто',
			'Подготовить соус',
			'Выпечь пиццу',
			'Съесть её!'
		]
	});
});

app.listen(3000, () => console.log('Mock AI API on http://localhost:3000'));