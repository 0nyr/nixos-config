# Session secrets held in the gnome-keyring "login" keyring.
#
# Unlock chain (per host, already configured elsewhere):
#   services.gnome.gnome-keyring.enable            -> runs the secret-service daemon
#   security.pam.services.<dm>.enableGnomeKeyring  -> unlocks the "login" keyring
#                                                     with the password typed at the
#                                                     display manager
# On kenzae the display manager is greetd/tuigreet (hosts/kenzae/configuration.nix),
# on aezyr it is sddm (hosts/aezyr/configuration.nix). Nothing in this file enables
# the daemon: it only *consumes* it, through libsecret's `secret-tool` client.
#
# This is the interactive-desktop half of secret management. The zynzen server uses
# sops-nix instead (age-encrypted files checked into a private repo), because there
# is no session, no password prompt, and no keyring daemon there.
#
# Adding a secret:
#   1. store it once, by hand (the value must never enter the Nix store or git):
#        secret-tool store --label="<label>" service <service> account 0nyr
#   2. add an entry to `exportedSecrets` or `wrappedSecrets` below
#   3. nixos-rebuild switch, then open a new terminal
#
# Inspect what is declared and what is actually present with `keyring-status`.
{ config, pkgs, lib, ... }:

let
  # Every secret is stored under the same libsecret account attribute; `service`
  # is what distinguishes them.
  account = "0nyr";

  # --- Secrets exported into the environment of every interactive shell. -------
  # Use this for plain API keys whose client reads a well-known variable and has
  # no token store of its own. Tradeoff: the value sits in the environment of
  # every process spawned from a shell, so it is readable through /proc/<pid>/environ
  # by you and by root. Acceptable for API keys on a single-user laptop; not
  # acceptable for anything that would also be a valid credential elsewhere.
  exportedSecrets = [
    {
      service = "openrouter";
      var = "OPENROUTER_API_KEY";
      label = "OpenRouter API key";
    }
  ];

  # --- Secrets exposed only through a wrapper function. ------------------------
  # The value is fetched at call time and lives only in the environment of the one
  # command being run. Use this when the secret is powerful, rarely needed, or
  # would conflict with a tool's own credential store.
  #
  # fn  : name of the shell function to define
  # cmd : the command it wraps
  # var : the variable set for that single invocation
  # hint: extra line printed when the lookup comes back empty ("" for none)
  wrappedSecrets = [
    {
      service = "gh-mamut";
      var = "GH_TOKEN";
      fn = "gh-mamut";
      cmd = "gh";
      label = "gh ANR-MAMUT PAT";
      # `gh` stores exactly one token per host per account, and the personal
      # fine-grained PAT is owned by `0nyr`, so it cannot act on ANR-MAMUT
      # resources: org-owned repos need a token whose *resource owner* is the org
      # (verified 2026-07-18: collaborators and actions/secrets both return
      # "403 Resource not accessible by personal access token"). The `permissions`
      # field the API returns on those repos reflects the *user's* rights, not the
      # token's, so it misleadingly reads `admin: true`. Overriding per invocation
      # keeps personal-repo `gh` access working.
      hint = "Create the token at https://github.com/settings/personal-access-tokens/new (Resource owner: ANR-MAMUT).";
    }
  ];

  lookup = s: "secret-tool lookup service ${s.service} account ${account} 2>/dev/null";
  storeCmd = s: ''secret-tool store --label="${s.label}" service ${s.service} account ${account}'';

  # The empty guard matters in both directions: an unset variable makes a client
  # say "no credentials", while an empty one usually makes it attempt an
  # unauthenticated request and fail later with a confusing 401/404.
  mkExport = s: ''
    _keyring_tok="$(${lookup s})"
    if [ -n "$_keyring_tok" ]; then export ${s.var}="$_keyring_tok"; fi
    unset _keyring_tok
  '';

  mkWrapper = s: ''
    ${s.fn}() {
      local _keyring_tok
      _keyring_tok="$(${lookup s})"
      if [ -z "$_keyring_tok" ]; then
        echo "${s.fn}: no secret for service '${s.service}' in the keyring." >&2
        echo "Store one with:" >&2
        echo '  ${storeCmd s}' >&2
        ${lib.optionalString (s.hint != "") ''echo "${s.hint}" >&2''}
        return 1
      fi
      ${s.var}="$_keyring_tok" ${s.cmd} "$@"
    }
  '';

  # Reports presence only, never values.
  mkStatusLine = kind: s: ''
    if [ -n "$(${lookup s})" ]; then _keyring_mark="present"; else _keyring_mark="MISSING"; fi
    printf '  %-10s %-12s %-22s %s\n' "${kind}" "${s.service}" "${s.var}" "$_keyring_mark"
  '';
in
{
  # Client for the gnome-keyring secret service. Deliberately at OS level rather
  # than in a dev shell: it is never a build input, and the wrappers below must
  # work in plain non-dev-shell terminals, which is where they are actually used.
  environment.systemPackages = [ pkgs.libsecret ];

  # NB: environment.interactiveShellInit is types.lines, so this merges with the
  # blocks defined in modules/packages.nix and modules/gui/sway.nix rather than
  # conflicting with them.
  environment.interactiveShellInit = ''
    # --- keyring-backed secrets (modules/keyring-secrets.nix) ---
    # Exports are skipped without a session bus (bare TTY, plain SSH): the keyring
    # is locked there, every lookup would block or fail, and shell startup would
    # pay for it on each new shell.
    if [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then
      ${lib.concatMapStringsSep "\n" mkExport exportedSecrets}
    fi

    ${lib.concatMapStringsSep "\n" mkWrapper wrappedSecrets}

    keyring-status() {
      local _keyring_mark
      printf '  %-10s %-12s %-22s %s\n' "KIND" "SERVICE" "VARIABLE" "STATE"
      ${lib.concatMapStringsSep "\n" (mkStatusLine "exported") exportedSecrets}
      ${lib.concatMapStringsSep "\n" (mkStatusLine "wrapped") wrappedSecrets}
    }
  '';
}
