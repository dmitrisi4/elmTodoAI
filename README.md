node 18.17.0
elm 0.19.1

build elm
elm make src/Main.elm --output=elm.js

server start
node mock-server.js

create:
.env
GEMINI_API_KEY=your-gemini-api-key

get available models:
curl "https://generativelanguage.googleapis.com/v1beta/models?key=your-gemini-api-key"



	1.	🔗 Подключить HTTP-запрос к AI (реальный или мок-сервер)
	2.	📦 Разбить код на модули: Api, Components, Pages
	3.	📌 Сделать тудушки интерактивными (состояние “выполнено”/“не выполнено”)
	4.	💾 Добавить сохранение в LocalStorage
	5.	🧠 Настроить бэкенд, который будет говорить с Gemini или GPT