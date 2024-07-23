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

## Initial Settings in Open WebUI
* Sign up as the first user -> this guy will be the super admin
<img width="441" alt="Screenshot 2567-07-23 at 22 50 17" src="https://github.com/user-attachments/assets/2af2c24a-0715-4111-b78b-d88489dd57df">
* Sign in and see your first login
<img width="1715" alt="Screenshot 2567-07-23 at 23 10 16" src="https://github.com/user-attachments/assets/a7c17cb3-d63a-460b-bad1-f3ffca190234">
* Go get model in ollama.com
![Facebook post image (1)](https://github.com/user-attachments/assets/dc7d3120-6a93-4388-963f-2581f0d53ef6)
* Access 'models' in Admin Panel
<img width="372" alt="Screenshot 2567-07-23 at 23 10 57" src="https://github.com/user-attachments/assets/6679836b-dea9-40f0-8d45-e48204fa926d">
* Download and use
