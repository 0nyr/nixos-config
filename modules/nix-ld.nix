# nix-ld: a system-wide shim that lets unpatched, dynamically-linked binaries
# (vendor SDKs, prebuilt solvers) start on NixOS. Such binaries hardcode
# /lib64/ld-linux-x86-64.so.2 as their ELF interpreter, a path NixOS does not
# provide: nixpkgs plants a `stub-ld` there whose only job is to print an error.
# nix-ld replaces that stub and forwards to the real loader in the store.
#
# DELIBERATELY NOT ENABLED. Prefer patchelf on the individual binary. It keeps
# the impurity local to the one file that needs it, leaves the rest of the
# system failing loudly on undeclared binaries, and avoids nix-ld's sharp edge:
# version 2.0.6 performs no AT_SECURE check, so a setuid foreign binary would
# honour an attacker-controlled NIX_LD. No such binary exists here (every
# setuid file is a nixpkgs security-wrapper), but a standing system-wide
# exposure is not worth the convenience. Uncomment the line below only if some
# vendor binary ever resists patchelf.
#
#   programs.nix-ld.enable = true;
#
# --- patchelf recipe (verified 2026-07-29 on Hexaly Optimizer 15.0) ---
#
# Take the loader and libstdc++ from the CURRENT SYSTEM closure, not from a dev
# shell: system store paths are pinned by the running generation and survive
# nix-collect-garbage, whereas nix-dev-base's own glibc and gcc are collectable
# and would silently break the binary at the next GC. The ELF64 filter is
# required, because hardware.graphics.enable32Bit drags an i686 gcc-*-lib into
# the closure and picking it fails with "wrong ELF class: ELFCLASS32".
#
#   SYS_LD=$(readelf -l /run/current-system/sw/bin/htop \
#              | sed -n 's/.*interpreter: \(.*\)\]/\1/p')
#   SYS_CXX=$(for p in $(nix-store -qR /run/current-system \
#                          | grep -E 'gcc-[0-9.]+-lib$'); do
#       f=$p/lib/libstdc++.so.6
#       [ -e "$f" ] \
#         && [ "$(readelf -h "$f" | awk '/Class:/{print $2}')" = ELF64 ] \
#         && echo "$p"
#       true
#     done | sort | head -1)
#   patchelf --set-interpreter "$SYS_LD" --set-rpath "\$ORIGIN:$SYS_CXX/lib" \
#            /home/onyr/hexaly150/bin/hexaly
#   patchelf --set-rpath "\$ORIGIN:$SYS_CXX/lib" \
#            /home/onyr/hexaly150/bin/libhexaly150.so
#
# $ORIGIN makes bin/hexaly find bin/libhexaly150.so beside itself, so the
# executable then runs from any shell, with LD_LIBRARY_PATH unset. Re-run the
# recipe after reinstalling Hexaly, and after a system nixpkgs bump followed by
# a garbage collection, since the baked store paths would be gone.
#
# The Python API is a separate matter. hexaly/optimizer.py ctypes-loads
# libhexaly150.so by soname from the *python* process, which carries none of
# our RPATHs, so it needs /home/onyr/hexaly150/bin on LD_LIBRARY_PATH. The
# shared base dev shell (/home/onyr/nix-dev-base) exports exactly that.
#
# See https://github.com/nix-community/nix-ld

{ config, pkgs, pkgs-stable, lib, ... }:

{
  # Intentionally empty: patchelf is preferred over nix-ld here, see above.
}
