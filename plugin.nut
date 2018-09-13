// --------------------
// Load Modules
// --------------------
fe.load_module("helpers");

// --------------------
// Plugin User Options
// --------------------
class UserConfig </ help="A plugin that selects a random game after a period of inactivity." /> {
	</ label="Delay Time",
		help="The amount of inactivity (seconds) before selecting a random game.",
		order=1 />
  delayTime="30";
}

// --------------------
// Sequencer
// --------------------
class Sequencer {
  config = null;

  time = null;
  delayTime = null;
  signalTime = null;
  target = null;
  active = null;
  signal = null;

  constructor() {
    config = fe.get_config();
      try {
        config["delayTime"] = config["delayTime"].tointeger();
        assert(config["delayTime"] >= 1);
      }
      catch (e) {
        print("ERROR in Sequencer Plugin: user options - improper delay time\n");
        config["delayTime"] = 30;
      }

    time = 0;
    delayTime = config["delayTime"]*1000;
    signalTime = 0;
    active = false;

    fe.add_ticks_callback(this, "updateTime");
    fe.add_transition_callback(this, "updateSignalTime");
    fe.add_ticks_callback(this, "status");
    fe.add_signal_handler(this, "blockSignals");
  }

  function updateTime(ttime) {
    time = ttime;
  }

  function updateSignalTime(ttype, var, ttime) {
    signalTime = time;
    return false;
  }

  function status(ttime) {
    // Activate Sequencer
    if (!active && (ttime >= signalTime + delayTime)) {
      active = true;
      target = randInt(fe.list.size - 1);

      // if difference in between is less than around
      if ( (abs(fe.list.index - target)) <= (abs(fe.list.size - abs(fe.list.index - target))) )
        (target >= fe.list.index) ? signal = "next_game" : signal = "prev_game";
      else
        (fe.list.index >= target) ? signal = "next_game" : signal = "prev_game";
    }

    // Deactivate or Go To Next Game
    if (active) {
      if (fe.list.index == target) active = false;
      else nextGame();
    }
  }

  function blockSignals(signal_str) {
    local blocked = null;

    if (active) {
      (signal != "next_game") ? blocked = "next_game" : "prev_game";
      switch (signal_str) {
        case blocked:
        case "prev_page":
        case "next_page":
        case "random_game":
        case "prev_letter":
        case "next_letter":
        case "prev_display":
        case "next_display":
        case "next_filter":
        case "prev_filter":
          return true;
      }
    }

    return false;
  }

  // PRIVATE FUNCTIONS

  function nextGame() {
    fe.signal(signal);
  }
}
fe.plugin["Sequencer"] <- Sequencer();
