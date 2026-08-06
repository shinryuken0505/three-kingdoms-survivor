# Alpha.31 Portrait and Relic Modal Hotfix

"
    "- Corrects Zhang Fei and Cao Cao portrait mappings after normal asset loading.
"
    "- Covers compact and formal runtime IDs.
"
    "- Prevents sprite strips from serving as their portrait fallback.
"
    "- Adds a development-time portrait reference audit for the full hero roster.
"
    "- Treats the relic notice as a blocking modal in `_process()`.
"
    "- While the notice is open, enemies, bosses, shots, zones, cooldowns, spawns, and chapter timers do not advance.
"
    "- Input and redraw remain active so the notice can be closed normally.
"
    