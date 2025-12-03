#!/usr/bin/env node
/*
#link-to: ~/.local/bin/race-commands
*/
/**
 * Command Racing Script
 *
 * Runs multiple commands concurrently and shows which one finishes first.
 * Useful for performance testing, benchmarking, or comparing alternative commands.
 *
 * Usage:
 *   node race-commands.js "command1" "command2" "command3"
 *   ./race-commands.js "afm build" "yarn build" "npm run build"
 */

const { spawn } = require("child_process");

// ANSI color codes
const colors = {
  reset: "\x1b[0m",
  bold: "\x1b[1m",
  dim: "\x1b[2m",

  // Text colors
  black: "\x1b[30m",
  red: "\x1b[31m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  magenta: "\x1b[35m",
  cyan: "\x1b[36m",
  white: "\x1b[37m",
  gray: "\x1b[90m",
};

// Helper functions for colored text
const colorize = (text, color) =>
  `${colors[color] || ""}${text}${colors.reset}`;
const bold = (text) => `${colors.bold}${text}${colors.reset}`;

class CommandRacer {
  constructor(commands) {
    this.commands = commands;
    this.results = [];
    this.startTime = null;
    this.finishedCount = 0;
  }

  formatTime(ms) {
    if (ms < 1000) return `${ms}ms`;
    if (ms < 60000) return `${(ms / 1000).toFixed(2)}s`;
    return `${(ms / 60000).toFixed(2)}m`;
  }

  formatCommand(cmd, index) {
    const colorNames = ["blue", "green", "yellow", "magenta", "cyan", "red"];
    const colorName = colorNames[index % colorNames.length];
    return colorize(`[${index + 1}] ${cmd}`, colorName);
  }

  logEvent(message, level = "info") {
    const timestamp = new Date().toISOString().substr(11, 8);
    const levelColors = {
      info: "gray",
      success: "green",
      error: "red",
      warn: "yellow",
    };
    const colorName = levelColors[level] || "gray";
    console.log(
      `${colorize(timestamp, "gray")} ${colorize(level.toUpperCase(), colorName)} ${message}`,
    );
  }

  async raceCommands() {
    if (this.commands.length === 0) {
      this.logEvent("No commands provided", "error");
      return;
    }

    console.log(bold("\n🏁 Command Race Starting!\n"));

    this.commands.forEach((cmd, index) => {
      console.log(`   ${this.formatCommand(cmd, index)}`);
    });

    console.log("\n" + "─".repeat(60) + "\n");

    this.startTime = Date.now();

    const promises = this.commands.map((command, index) => {
      return this.runCommand(command, index);
    });

    try {
      await Promise.allSettled(promises);
      this.showResults();
    } catch (error) {
      this.logEvent(`Race failed: ${error.message}`, "error");
    }
  }

  runCommand(command, index) {
    return new Promise((resolve) => {
      const startTime = Date.now();
      this.logEvent(`Starting ${this.formatCommand(command, index)}`);

      // Parse command and arguments
      const parts = command.trim().split(/\s+/);
      const cmd = parts[0];
      const args = parts.slice(1);

      const process = spawn(cmd, args, {
        stdio: ["ignore", "pipe", "pipe"],
        shell: true,
      });

      let stdout = "";
      let stderr = "";

      process.stdout?.on("data", (data) => {
        stdout += data.toString();
      });

      process.stderr?.on("data", (data) => {
        stderr += data.toString();
      });

      process.on("close", (code) => {
        const endTime = Date.now();
        const duration = endTime - startTime;
        const position = ++this.finishedCount;

        const result = {
          command,
          index,
          code,
          duration,
          position,
          stdout: stdout.trim(),
          stderr: stderr.trim(),
          success: code === 0,
        };

        this.results.push(result);

        const positionEmojis = ["🥇", "🥈", "🥉"];
        const emoji = positionEmojis[position - 1] || `${position}️⃣`;
        const status = result.success
          ? colorize("SUCCESS", "green")
          : colorize(`FAILED (${code})`, "red");

        this.logEvent(
          `${emoji} ${this.formatCommand(command, index)} - ${status} in ${this.formatTime(duration)}`,
          result.success ? "success" : "error",
        );

        resolve(result);
      });

      process.on("error", (error) => {
        const endTime = Date.now();
        const duration = endTime - startTime;
        const position = ++this.finishedCount;

        const result = {
          command,
          index,
          code: -1,
          duration,
          position,
          stdout: "",
          stderr: error.message,
          success: false,
          error: error.message,
        };

        this.results.push(result);
        this.logEvent(
          `${this.formatCommand(command, index)} - ERROR: ${error.message}`,
          "error",
        );
        resolve(result);
      });
    });
  }

  showResults() {
    console.log("\n" + "─".repeat(60));
    console.log(bold("\n🏆 RACE RESULTS\n"));

    // Sort by position (finish order)
    const sortedResults = [...this.results].sort(
      (a, b) => a.position - b.position,
    );

    sortedResults.forEach((result, index) => {
      const positionEmojis = ["🥇", "🥈", "🥉"];
      const emoji = positionEmojis[index] || `${index + 1}️⃣`;
      const status = result.success
        ? colorize("✓", "green")
        : colorize("✗", "red");
      const duration = this.formatTime(result.duration);

      console.log(
        `${emoji} ${status} ${this.formatCommand(result.command, result.index)} - ${duration}`,
      );

      if (!result.success && result.stderr) {
        console.log(
          `     ${colorize("Error:", "red")} ${result.stderr.split("\n")[0]}`,
        );
      }
    });

    // Show summary statistics
    const successful = this.results.filter((r) => r.success);
    const failed = this.results.filter((r) => !r.success);
    const totalTime = Date.now() - this.startTime;

    console.log("\n" + "─".repeat(60));
    console.log(bold("\n📊 SUMMARY\n"));
    console.log(`⏱️  Total race time: ${this.formatTime(totalTime)}`);
    console.log(`✅ Successful: ${successful.length}/${this.commands.length}`);
    console.log(`❌ Failed: ${failed.length}/${this.commands.length}`);

    if (successful.length > 0) {
      const winner = sortedResults.find((r) => r.success);
      const fastest = successful.reduce((prev, curr) =>
        prev.duration < curr.duration ? prev : curr,
      );

      console.log(
        `🏆 Winner: ${this.formatCommand(winner.command, winner.index)}`,
      );

      if (winner !== fastest) {
        console.log(
          `⚡ Fastest (including failures): ${this.formatCommand(fastest.command, fastest.index)}`,
        );
      }
    }

    console.log("");
  }
}

// CLI Interface
function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log(bold("Command Racing Script\n"));
    console.log(
      'Usage: node race-commands.js "command1" "command2" "command3"',
    );
    console.log("\nExamples:");
    console.log('  node race-commands.js "echo fast" "sleep 1 && echo slow"');
    console.log(
      '  ./race-commands.js "afm build" "yarn build" "npm run build"',
    );
    console.log(
      '  node race-commands.js "ping -c 3 google.com" "ping -c 3 github.com" "ping -c 3 stackoverflow.com"',
    );
    console.log("");
    process.exit(1);
  }

  const racer = new CommandRacer(args);
  racer.raceCommands().catch((error) => {
    console.error(colorize(`\nRace failed: ${error.message}`, "red"));
    process.exit(1);
  });
}

// Handle Ctrl+C gracefully
process.on("SIGINT", () => {
  console.log(colorize("\n\n⚠️  Race interrupted by user", "yellow"));
  process.exit(0);
});

if (require.main === module) {
  main();
}

module.exports = CommandRacer;
