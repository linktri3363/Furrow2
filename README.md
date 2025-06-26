Furrow2 Addon v3.0 - User Guide
Overview
Furrow2 is an automated gardening addon for Final Fantasy XI that manages your Mog Garden furrows. It automates the complete cycle of planting seeds, applying fertilizer, and harvesting crops with precise timing and error handling. Created by Linktri & Algar.

Features
Automated Full Cycle: Plant → Fertilize → Wait 30 minutes → Harvest
Smart Targeting: Automatically finds and targets all three Garden Furrows
Flexible Items: Supports any seed and fertilizer items
Timing Reminders: Regular notifications during wait periods
Error Recovery: Robust error handling and retry mechanisms
Manual Control: Individual commands for plant, fertilize, or harvest operations
Requirements
Mog Garden Access: Must have access to your Mog Garden
Garden Furrows: At least one furrow must be unlocked (works with 1, 2, or 3 furrows)
Items in Inventory: Seeds and fertilizer must be in your inventory
Positioning: Stand near the furrows before starting
Installation
Place furrow2.lua in your Windower addons folder
Load the addon with //lua load furrow2 or add to startup
Verify installation with //fu help
Default Settings
The addon is designed to work flexibly with your current furrow setup:

1 Furrow Available: Will plant, fertilize, and harvest that single furrow
2 Furrows Available: Will process both available furrows
3 Furrows Available: Will process all three furrows (maximum efficiency)
Success Criteria: The cycle continues as long as at least one furrow is successfully processed in each phase. You'll see status messages like "Successfully planted 2 out of 3 furrows" to track progress.

Upgrading: As you unlock additional furrows, the addon will automatically detect and use them without any configuration changes.

Default Seed: "Revival Root"
Default Fertilizer: "Miracle Mulch"
Harvest Wait Time: 30 minutes after fertilizing
Debug Mode: Disabled
Commands
Main Commands
//fu start [seed] [fertilizer]
//furrow2 start [seed] [fertilizer]
Begins the full automated cycle with optional custom items.

Example: //fu start "Revival Root" "Miracle Mulch"
Example: //fu start (uses defaults)
//fu stop
//fu abort
Immediately stops all running operations.

//fu status
Shows current status, elapsed time, and active operations.

Individual Operations
//fu plant [seed]
Performs only the planting cycle.

Example: //fu plant "Gysahl Greens"
//fu fertilize [fertilizer]
Performs only the fertilizing cycle.

Example: //fu fertilize "Tree Cuttings"
//fu harvest
Performs only the harvesting cycle.

Configuration
//furrow config debug
Toggles debug mode on/off for detailed logging.

//furrow config seed <name>
Changes the default seed item.

Example: //furrow config seed "Gysahl Greens"
//furrow config fertilizer <name>
Changes the default fertilizer item.

Example: //furrow config fertilizer "Tree Cuttings"
//furrow help
Displays all available commands and current defaults.

Operation Cycle
Full Automated Cycle
Planting Phase: Targets each available furrow and plants the specified seed
Fertilizing Phase: Immediately applies fertilizer to each planted furrow
Waiting Phase: Waits 30 minutes with periodic reminders
Harvesting Phase: Harvests all mature crops
Loop: Automatically restarts the cycle (optional)
Note: The addon works with 1, 2, or 3 furrows. It will process all available furrows and continue the cycle as long as at least one furrow is successfully handled in each phase.

Timing Details
Plant → Fertilize: Immediate (no delay)
Fertilize → Harvest: Configurable wait time (default: 30 minutes)
Reminders: At 20, 10, and 5 minutes remaining
Usage Tips
Before Starting
Check Inventory: Ensure you have enough seeds and fertilizer
Position Yourself: Stand in your Mog Garden near the furrows
Clear Target: Make sure no important target is selected
Zone Stability: Avoid starting during server maintenance
Set Wait Time: Use //fu config waittime <minutes> if you want custom timing
Best Practices
Use //fu status to monitor progress
Keep the game window active during menu navigation
Don't move your character during active operations
Use //fu stop before logging out or changing zones
Use //fu config show to verify your settings
Item Names
Use exact item names with proper capitalization
Enclose multi-word items in quotes: "Revival Root"
Common fertilizers: "Miracle Mulch", "Tree Cuttings", "Vegetable Scraps"
Common seeds: "Revival Root", "Gysahl Greens", "La Theine Cabbage"
Troubleshooting
Common Issues
"Could not find Garden Furrow"

Solution: Stand closer to the furrows and clear your target
Note: The addon will continue if it finds at least one furrow
Only aborts if no furrows can be found at all
"Item not found" errors

Solution: Verify item names and inventory
Ensure items are not in storage or on other characters
Menu navigation problems

Solution: Keep game window active and avoid input during operations
Stop the addon and restart if menus get stuck
Cycle stops unexpectedly

Solution: Check chat log for error messages
Use //fu status to see what happened
Restart with //fu start
Debug Mode
Enable debug mode for detailed operation logging:

//fu config debug
This will show additional information about targeting and menu navigation.

Manual Recovery
If automated operations fail:

Use //fu stop to halt operations
Manually complete any stuck menu interactions
Check your position and inventory
Restart with individual commands: //fu plant, //fu fertilize, //fu harvest
Safety Features
Operation Locks: Prevents multiple operations from running simultaneously
User Abort: Can stop operations at any time with //furrow stop
Error Logging: Clear error messages for troubleshooting
Cleanup: Automatically stops operations when addon unloads
Version History
v3.0: Added configurable wait times, renamed to Furrow2 with short command //fu
v2.1: Added fertilize cycle and 30-minute wait timing
v2.0: Enhanced targeting, error handling, and menu navigation
v1.x: Basic plant and harvest functionality
Support
For issues or questions:

Check this user guide first
Enable debug mode to see detailed operation logs
Verify your setup meets all requirements
Report persistent issues with specific error messages
Note: This addon automates game actions. Use responsibly and in accordance with server rules. Always monitor the addon's operation and be prepared to take manual control if needed.
