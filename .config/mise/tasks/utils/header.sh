#!/usr/bin/env bash
#MISE hide=true
#MISE description="Forge project header/logo"

cat << 'EOF'
    __________  ____  ____________
   / ____/ __ \/ __ \/ ____/ ____/
  / /_  / / / / /_/ / / __/ __/
 / __/ / /_/ / _, _/ /_/ / /___
/_/    \____/_/ |_|\____/_____/
EOF

# Project tagline
if command -v gum &> /dev/null; then
    echo ""
    gum style \
        --foreground 240 \
        --italic \
        "Bootstrap • mise • pitchfork • localias"
    echo ""
    echo "mise start"
    echo "mise //:start # to run all services"
    echo "mise ls --all"
    echo ""
else
    echo ""
    echo "Bootstrap • mise • pitchfork • localias"
    echo ""
fi
