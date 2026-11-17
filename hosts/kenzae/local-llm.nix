# Local LLM on Kenzae, an offline backup for everyday IT help.
# Notes and decisions: phd_note_vault/docs/AILOGS/2026-11-16-local-llm-1.md
{ config, pkgs, lib, ... }:

let
  server = lib.getExe' pkgs.llama-cpp-cuda "llama-server";
  # GGUF files, downloaded by hand (not through Nix, to keep them out of
  # /nix/store). The service runs with ProtectHome, so they cannot live in ~.
  modelsDir = "/var/lib/llama-models";
  # Flags shared by every model. Thinking stays on by default (template
  # default of Qwen3.6, forced on for Qwen3.5-9B below). Sampling is the
  # thinking-mode "general tasks" preset of the Unsloth guides for Qwen3.5 and
  # Qwen3.6, with presence penalty 1.5 for both. The "precise coding" preset
  # (temperature 0.6) made Qwen3.6 loop in its thinking on a simple NixOS
  # question (2026-11-17). The thinking budget bounds the time of a turn: past
  # 4096 tokens, llama-server injects the message and closes the thinking.
  common = lib.concatStringsSep " " [
    "--port \${PORT}"
    "-fa on -ctk q8_0 -ctv q8_0" # flash attention, 8-bit KV cache
    "-np 1" # one slot, so a request gets the whole context
    "--jinja"
    "--temp 1.0 --top-p 0.95 --top-k 20 --min-p 0 --presence-penalty 1.5"
    "--reasoning-budget 4096"
    "--reasoning-budget-message 'I have thought long enough, I now give my answer.'"
  ];
  # Every model gets a "<name>:nothink" alias in the same process (no reload):
  # thinking off, with the non-thinking sampling of the same guides. It is
  # the fallback for the Qwen bug where a tool call is written inside the
  # thinking block (llama.cpp issue 20837).
  thinkingParams = {
    "\${MODEL_ID}".chat_template_kwargs.enable_thinking = true;
    "\${MODEL_ID}:nothink" = {
      chat_template_kwargs.enable_thinking = false;
      temperature = 0.7;
      top_p = 0.8;
      presence_penalty = 1.5;
    };
  };
in
{
  # Binary cache of the NixOS CUDA team. The CUDA builds of nixpkgs (unfree)
  # are not on cache.nixos.org, and without this cache the first rebuild that
  # asks for llama-cpp-cuda compiles the whole CUDA stack. It must be active in
  # /etc/nix/nix.conf (one rebuild) before any CUDA package is requested.
  # URL and key from https://wiki.nixos.org/wiki/CUDA (checked 2026-11-17).
  nix.settings = {
    extra-substituters = [ "https://cache.nixos-cuda.org" ];
    extra-trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  # One llama-server per model, started by llama-swap at the first request
  # and killed after 5 minutes without requests, so that the NVIDIA GPU can
  # suspend again (a sleeping llama-server would keep a CUDA context open).
  # Endpoint: http://127.0.0.1:8080/v1 (OpenAI-compatible), web UI on /ui.
  services.llama-swap = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 8080;
    settings = {
      healthCheckTimeout = 180; # the 35B model takes a while to load
      globalTTL = 300;
      # Monitoring: proxy, upstream (llama-server timings) and HTTP access logs
      # go to the journal (journalctl -u llama-swap). The activity history and
      # the request/response captures (they show the thinking) stay in memory
      # until llama-swap restarts, and are browsed on /ui. An on-disk history
      # (store.path) is not set, because validateConfigFile checks the config
      # inside the build sandbox, where the directory does not exist.
      logToStdout = "both";
      captureBuffer = 50; # MB of compressed captures
      models = {
        "qwen3.5-9b" = {
          cmd = "${server} -m ${modelsDir}/Qwen3.5-9B-Q4_K_M.gguf -ngl 99 -c 32768 ${common}";
          filters.setParamsByID = thinkingParams;
        };
        # MoE, 3B active: attention on the GPU, the experts of the first
        # --n-cpu-moe layers in RAM. 30 is a starting point, to be lowered
        # until loading fails, then raised by 1 or 2.
        "qwen3.6-35b-a3b" = {
          cmd = "${server} -m ${modelsDir}/Qwen3.6-35B-A3B-UD-IQ4_XS.gguf -ngl 99 --n-cpu-moe 30 -c 32768 -t 6 -ub 512 ${common}";
          filters.setParamsByID = thinkingParams;
        };
      };
    };
  };

  systemd.tmpfiles.rules = [ "d ${modelsDir} 0755 onyr users -" ];
}
