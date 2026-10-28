# IT-PAT-2026
My grade 11 IT PAT

# Setup
1. Clone repo.
2. Download qwen2.5-0.5b-instruct-q4_k_m.gguf from Hugging Face, [here](https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf?download=true).
3. In IT-PAT-2026/Win64/Debug create a folder called "models", and put the .gguf file in there.
4. Use GetIt to install OpenAI for Delphi.
5. Clone [this repo](https://github.com/B0lty/OpenAI-delphi-package)_and replace the files in "OpenC:\Users\[USERNAME]\Documents\Embarcadero\Studio\[BDS version]\CatalogRepository\OpenAIforDelphi" with the files from the repo.
6. Done! You can (hopefully) now run the project. 

# To-do:
Nothing yet.

# Far-fetched to-do: (not happening)
- [ ] Update login system
- [ ] Add a closed/open flag to each order, closed once a bill is exported
- [ ] Be able to edit the latest open order for a table
- [ ] Not be able to create a new order for a table if there is already an open order for that table
