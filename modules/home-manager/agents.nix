# dotagents (~/.agents) symlink map + scripts on PATH.
#
# Uses mkOutOfStoreSymlink so the links point at the live ~/.agents working tree
# (edits to linked *content* need no rebuild). Skills are NOT symlinked for Codex
# — Codex reads user skills natively from ~/.agents/skills.
{ config, ... }:
let
  agents = "/home/onyr/.agents";
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  # --- Claude Code ---
  home.file.".claude/CLAUDE.md".source = link "${agents}/claude/CLAUDE.md";
  home.file.".claude/commands".source = link "${agents}/claude/commands";
  home.file.".claude/agents".source = link "${agents}/claude/agents";
  home.file.".claude/skills".source = link "${agents}/skills";

  # --- Codex (instructions only; skills read natively from ~/.agents/skills) ---
  home.file.".codex/AGENTS.md".source = link "${agents}/AGENTS.md";

  # --- Shared scripts on PATH ---
  home.sessionPath = [
    "${agents}/scripts"
  ];
}
