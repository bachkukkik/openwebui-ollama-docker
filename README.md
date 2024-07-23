# openwebui-ollama-docker
basic Open WebUI + Ollama stack for Local ChatGPT

## Basic Usage
1. Clone this repository
2. `$ cd openwebui-ollama-docker`
3. `$ cp .env.example .env`
4. Edit `.env` file to your liking
5. `$ cp ./searxng/settings.yml.example ./searxng/settings.yml`
6. Edit `./searxng/settings.yml` file to your liking
7. `$ docker-compose up -d`
8. Open your browser and go to `http://localhost:8080`