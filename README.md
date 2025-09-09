# 🏠 Local-ChatGPT Stack  

**“Your own private ChatGPT-in-a-box”** – powered by Docker, Open-WebUI, Ollama, LiteLLM, SearXNG, vLLM, MinIO, Postgres & Redis.  
Zero cloud deps. 100 % local. GPU-ready. Prod-grade.

---

## 🔍 TL;DR  

1. `git clone … && cd openwebui-ollama-docker`  
2. `cp .env.example .env && nano .env`          # choose models, keys, passwords  
3. `cp searxng/settings.yml.example searxng/settings.yml`  
4. `docker compose up -d`                      # 3 files auto-merged  
5. Browse → <http://localhost:8080>              # start chatting  
   API → <http://localhost:8080/api>              # OpenAI-compatible  
   LiteLLM proxy → <http://localhost:4000>        # unified LLM gateway  

---

## 🧱 Architecture Overview

| Component | Role | Default alias | Image |
|-----------|------|---------------|-------|
| **open-webui** | Chat UI, RAG, users, workspaces | `ood-open-webui` | `ghcr.io/open-webui/open-webui:main` |
| **ollama** | Local LLM inference server | `ood-ollama` | `ollama/ollama:latest` |
| **vllm** | High-throughput inference / reranker | `ood-vllm` | `vllm/vllm-openai:latest` |
| **litellm** | Universal gateway (OpenAI ⇆ Ollama ⇆ 100+ clouds) | `ood-litellm` | `ghcr.io/berriai/litellm-database:main-latest` |
| **litellm_postgres** | LiteLLM metering, keys, spend tracking | `ood-litellm-postgres` | `pgvector:pg17` |
| **litellm_redis** | LiteLLM rate-limit & caching | `ood-litellm-redis` | `redis:alpine` |
| **postgres** | Open-WebUI vector DB & chat history | `ood-postgres` | `pgvector:pg17` |
| **redis** | OWUI real-time websockets / job queue | `ood-redis` | `redis:8-alpine` |
| **searxng** | Private meta-search for RAG web-search | `ood-searxng` | `searxng/searxng:latest` |
| **mcpo** | Model-Context-Protocol server (tools) | `ood-mcpo` | `ghcr.io/open-webui/mcpo:latest` |
| **minio** | S3-compatible object store (file uploads, images) | `ood-minio` | `minio/minio` |
| **minio-createbucket** | One-shot bucket creation | `ood-minio-createbucket` | `minio/mc` |

All services share one bridge network (`default`) and communicate via internal aliases – no port clashes, no outward exposure unless you uncomment `ports:`.

---

## 📁 Repository Layout

```bash
.
├── docker-compose.llm.yml       # ollama, open-webui, vllm, searxng, mcpo
├── docker-compose.db.yml        # postgres, redis, minio
├── docker-compose.litellm.yml   # litellm, litellm_postgres, litellm_redis
├── .env.example                 # 90+ variables documented inline
├── litellm/config.yaml          # router, fallback, budget, guardrails
├── litellm/.credentials/        # cloud keys (vertex_ai.json, aws.json …)
├── mcpo/config.json.example     # MCP tools (brave-search, filesystem …)
├── searxng/settings.yml         # privacy search engines, output format
└── volumes_minio/
    └── minio-entrypoint.sh      # auto-creates bucket on first run
```

Compose files are **loaded automatically** when you run with bash variable environment and run `docker compose up -d`

```bash
## see .env.example
COMPOSE_FILE=docker-compose.db.yml:docker-compose.llm.yml:docker-compose.litellm.yml
```

Compose files can be **specified** when you run  
`docker compose -f docker-compose.db.yml -f docker-compose.llm.yml -f docker-compose.litellm.yml up -d`

---

## ⚙️ Environment Cheat-Sheet

| Key | Purpose | Typical value |
|-----|---------|---------------|
| `OLLAMA_BASE_URL` | Where OWUI finds Ollama | `http://ollama:11434` |
| `RAG_RERANKING_MODEL` | Rerank snippets before context | `BAAI/bge-reranker-v2-m3` |
| `SEARXNG_QUERY_URL` | Web-search endpoint | `http://searxng:8080/search?q=<query>` |
| `WEBUI_SECRET_KEY` | JWT & cookie secret | `openssl rand -hex 32` |
| `LITELLM_MASTER_KEY` | Admin key for LiteLLM proxy | `sk-...` |
| `MINIO_ROOT_USER/PW` | S3 creds (also used by OWUI) | `minioadmin` / `minioadmin` |
| `USE_CUDA_DOCKER` | Enable GPU flags | `true` |
| `VOLUME_DOCKER` | Host path for all volumes | `/home/pi/docker_volumes` |

Full list inlined in `.env.example` – every variable is optional; defaults are sane for an 8 GB ARM board.

---

## 🚀 Model Life-Cycle

1. **Pull**  
   Inside open-webui → **Settings → Models → Ollama → Pull**  
   or `docker exec -it ollama ollama pull llama3.2:3b`

2. **Register in LiteLLM (optional)**  
   Edit `litellm/config.yaml` → add model block with `model_name: ollama/llama3.2:3b`  
   Restart litellm container → immediately callable via OpenAI SDK pointing to `http://localhost:4000`

3. **Consume**  
   - Chat UI: <http://localhost:8080>  
   - OpenAI-compatible API:  

     ```bash
     curl http://localhost:8080/api/chat \
       -H "Authorization: Bearer $WEBUI_SECRET_KEY" \
       -d '{"model":"llama3.2:3b","messages":[{"role":"user","content":"hello"}]}'
     ```

   - LiteLLM gateway:  

     ```bash
     curl http://localhost:4000/v1/chat/completions \
       -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
       -d '{"model":"ollama/llama3.2:3b","messages":[{"role":"user","content":"hello"}]}'
     ```

---

## 🧠 RAG & Agentic Features

| Feature | Service(s) involved | Toggle |
|---------|---------------------|--------|
| Hybrid vector + keyword search | Postgres pgvector + built-in FTS | `ENABLE_RAG_HYBRID_SEARCH=true` |
| Web-search augmentation | SearXNG | `ENABLE_RAG_WEB_SEARCH=true` |
| Document re-ranking | vLLM (reranker model) | `RAG_RERANKING_MODEL=BAAI/bge-reranker-v2-m3` |
| File upload (pdf, txt, md …) | MinIO + OWUI | `STORAGE_PROVIDER=s3` |
| Persistent chat threads | Postgres | already enabled |
| Function-calling / tools | MCPO | edit `mcpo/config.json` |

---

## 🔐 Security & Privacy

- No ports bound to host by default – reverse-proxy (Traefik, Nginx, Cloudflare-Tunnel) ready.  
- SearXNG removes trackers, no logs.  
- LiteLLM supports virtual keys, budget caps, user roles.  
- All volumes stored locally (`/home/pi/docker_volumes/*`) – wipe folder = zero residue.  
- Optional: set `ENV=dev` to enable openai-compatible from Open-WebUI, `GLOBAL_LOG_LEVEL=DEBUG` for verbose logs.

---

## 🐛 Troubleshooting

| Symptom | Fix |
|---------|-----|
| `ollama pull` hangs | give container at least 4 GB RAM; on ARM set `OLLAMA_FLASH_ATTENTION=0` |
| open-webui shows “Connection refused” to ollama | check `OLLAMA_BASE_URL` uses internal alias `http://ollama:11434` |
| LiteLLM 401 | supply `LITELLM_MASTER_KEY` and use same key in client |
| SearXNG CAPTCHA | choose more engines in `settings.yml` or enable `limiter.toml` |
| GPU not visible | uncomment `deploy.resources.reservations.devices` in ollama & vllm services; install nvidia-container-toolkit |

---

## 📈 Hardware Baseline

| Tier | RAM | Disk | GPU | Notes |
|------|-----|------|-----|-------|
| **Pocket** | 8 GB | 32 GB | — | 3 B model, CPU 4 t/s |
| **Laptop** | 16 GB | 100 GB | 8 GB VRAM | 8 B model + embeddings |
| **Workstation** | 32 GB | 1 TB | 24 GB VRAM | 70 B GGUF + vLLM 4-bit |

All tiers share the same compose – only model sizes and `deploy.limits` differ.

---

## 🧹 Stop / Reset

```bash
docker compose down -v              # wipe everything
docker compose down                 # keep volumes (chat history, models)
docker system prune -a              # reclaim space
```

---

## 📄 License

MIT – see LICENSE file.  
Upstream projects keep their respective licenses.

---

## 🤝 Contribute

PRs welcome!  
Please run `pre-commit run --all-files` before push (yamlfmt, shellcheck, markdownlint).

---

**Enjoy your completely offline,API-compatible, GPU-accelerated ChatGPT clone!**  
If this repo saved you a week, leave a ⭐ and share your `docker stats` screenshots.
