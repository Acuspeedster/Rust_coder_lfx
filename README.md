# Rust Project Generator API

An API service that generates fully functional Rust projects from natural language descriptions. This service leverages LLMs to create Rust code, compiles it, and automatically fixes any errors.

---

## ✨ Features

- **Generate Rust Projects** 📦 - Transform text descriptions into complete Rust projects.
- **Automatic Compilation & Fixing** 🛠 - Detect and resolve errors during compilation.
- **Vector Search** 🔍 - Search for similar projects and errors.
- **Docker Containerization** 🐳 - Easy deployment with Docker.
- **Asynchronous Processing** ⏳ - Handle long-running operations efficiently.

---

## 📋 Prerequisites

Ensure you have the following installed:

- **Docker & Docker Compose** 🐳

Or, if you want to run the services directly on your own computer:

- **Python 3.8+** 🐍
- **Rust Compiler and cargo tools** 🦀 

---

## 📦 Install

```bash
git clone <repository-url>
cd Rust_coder_lfx
```

## 🚀 Configure and run

### Using Docker (Recommended)

Edit the `docker-compose.yml` file and specify your own LLM API server. The default config assumes that you have a [Gaia node like this](https://github.com/GaiaNet-AI/node-configs/tree/main/qwen-2.5-coder-3b-instruct-gte) running on `localhost` port `8080`. The alternative configuration shown below uses a [public Gaia node for coding assistance](https://docs.gaianet.ai/nodes#coding-assistant-agents).

```
- LLM_API_BASE=https://coder.gaia.domains/v1
- LLM_MODEL=Qwen2.5-Coder-32B-Instruct-Q5_K_M
- LLM_EMBED_MODEL=nomic-embed
- LLM_API_KEY=<YOUR API KEY FROM GAIANET.AI>
- LLM_EMBED_SIZE=768
```

Start the services.

```bash
docker-compose up -d
```

Stop the services.

```bash
docker-compose stop
```

### Manual Setup

By default, you will need a [Qdrant server](https://qdrant.tech/documentation/quickstart/) running on `localhost` port `6333`. You also need a [local Gaia node](https://github.com/GaiaNet-AI/node-configs/tree/main/qwen-2.5-coder-3b-instruct-gte). Set the following environment variables in your terminal to point to the Qdrant and Gaia instances, as well as your Rust compiler tools.

```
QDRANT_HOST
QDRANT_PORT
LLM_API_BASE
LLM_MODEL
LLM_EMBED_MODEL
LLM_API_KEY
LLM_EMBED_SIZE
CARGO_PATH
RUST_COMPILER_PATH
```

Start the services.

```bash
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

---

## 🔥 Usage

The API provides the following endpoints:

### 🎯 Generate a Project

**Endpoint:** `POST /generate`

**Example:**

```bash
  curl -X POST http://localhost:8000/generate \
  -H "Content-Type: application/json" \
  -d '{"description": "A command-line calculator in Rust", "requirements": "Should support addition, subtraction, multiplication, and division"}'
```

#### 📥 Request Body:

```json
{
  "description": "A command-line calculator in Rust",
  "requirements": "Should support addition, subtraction, multiplication, and division"
}
```

#### 📤 Response:

```json
{
  "project_id": "123e4567-e89b-12d3-a456-426614174000",
  "status": "processing",
  "message": "Project generation started"
}
```

### 📌 Check Project Status

**Endpoint:** `GET /project/{project_id}`

**Example:**

```bash
curl http://localhost:8000/project/123e4567-e89b-12d3-a456-426614174000
```

#### 📤 Response:

```json
{
  "project_id": "123e4567-e89b-12d3-a456-426614174000",
  "status": "completed",
  "message": "Project generated successfully",
  "files": ["Cargo.toml", "src/main.rs", "README.md"],
  "build_output": "...",
  "run_output": "..."
}
```

---

## 🔧 MCP (Model-Compiler-Processor) tools

The MCP server is available via the HTTP SSE transport via the `http://localhost:3000/sse` URL. The MCP server can be accessed using the [cmcp command-line client](https://github.com/RussellLuo/cmcp). To install the `cmcp` tool,

```bash
pip install cmcp
```

### 🛠 Compile Rust Code

**tool:** `compile`

#### 📥 Request example:

```bash
cmcp http://localhost:3000 tools/call -d '{ \
    "name": "compile", \
    "arguments": { \
        "code: "[filename: Cargo.toml]\n[package]\nname = \"hello_world\"\nversion = \"0.1.0\"\nedition = \"2021\"\n\n[dependencies]\n\n[filename: src/main.rs]\nfn main() {\n    println!(\"Hello, World!\");\n}" \
    } \
}'
```

#### 📤 Response:

```json
{
  "meta": null,
  "content": [
    {
      "type": "text",
      "text": "success",
      "annotations": null
    }
  ],
  "isError": false
}
```

### 🩹 Compile and Fix Rust Code

**tool:** `compileAndFix`

### 📥 Request example:

```bash
cmcp http://localhost:3000 tools/call -d '{ \
    "name": "compileAndFix", \
    "arguments": { \
        "code: "[filename: Cargo.toml]\n[package]\nname = \"hello_world\"\nversion = \"0.1.0\"\nedition = \"2021\"\n\n[dependencies]\n\n[filename: src/main.rs]\nfn main() {\n    println!(\"Hello, World!\" // Missing closing parenthesis \n}" \
    } \
}'
```

### 📤 Response:

```json
{
  "meta": null,
  "content": [
    {
      "type": "text",
      "text": "[filename: Cargo.toml]\n[package]\nname = \"hello_world\"\nversion = \"0.1.0\"\nedition = \"2021\"\n\n[dependencies]\n\n[filename: src/main.rs]\nfn main() {\n    println!(\"Hello, World!\"); \n}",
      "annotations": null
    }
  ],
  "isError": false
}
```

### 🎯 Generate a new project

**tool:** `generate`

### 📥 Request example:

```bash
cmcp http://localhost:3000 tools/call -d '{ \
    "name": "generate", \
    "arguments": { \
        "description": "A command-line calculator in Rust", "requirements": "Should support addition, subtraction, multiplication, and division" \
    } \
}'
```

### 📤 Response:

```json
{
  "meta": null,
  "content": [
    {
      "type": "text",
      "text": "[filename: Cargo.toml] ... [filename: src/main.rs] ... ",
      "annotations": null
    }
  ],
  "isError": false
}
```

---

## 📂 Project Structure

```
Rust_coder_lfx/
├── app/                  # Application code
│   ├── compiler.py       # Rust compilation handling
│   ├── llm_client.py     # LLM API client
│   ├── main.py           # FastAPI application
│   ├── mcp_service.py    # Model-Compiler-Processor service
│   ├── prompt_generator.py # LLM prompt generation
│   ├── response_parser.py # Parse LLM responses into files
│   ├── vector_store.py   # Vector database interface
│   └── ...
├── data/                 # Data storage
│   ├── error_examples/   # Error examples for vector search
│   └── project_examples/ # Project examples for vector search
├── docker-compose.yml    # Docker Compose configuration
├── Dockerfile            # Docker configuration
├── examples/             # Example scripts for using the API
├── output/               # Generated project output
├── parse_and_save_qna.py # Q&A parsing utility
├── qdrant_data/          # Vector database storage
├── requirements.txt      # Python dependencies
└── templates/            # API templates
```

---


## 🧠 How It Works

Vector Search: The system uses Qdrant for storing and searching project examples and error solutions.

LLM Integration: Communicates with LlamaEdge API for code generation and error fixing via `llm_client.py`.

Compilation Feedback Loop: Automatically compiles, detects errors, and fixes them using `compiler.py`.

File Parsing: Converts LLM responses into project files with `response_parser.py`.

---

## 🤝 Contributing
Contributions are welcome! Feel free to submit a Pull Request. 🚀

---

## 📜 License
Licensed under [No license]](LICENSE).
