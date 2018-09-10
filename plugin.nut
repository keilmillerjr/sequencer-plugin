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
    fe.add_ticks_callback(this, "nextGame");
  }

  function updateTime(ttime) {
    time = ttime;
  }

  function updateSignalTime(ttype, var, ttime) {
    signalTime = time;
    return false;
  }

  function status(ttime) {
    if (!active && (ttime >= signalTime + delayTime)) {
      target = randInt(fe.list.size - 1);
      if (fe.list.index == target) return;
      active = true;

      if (fe.list.size - 1 - fe.list.index - target > 0) signal = "next_game";
      if (fe.list.size - 1 - fe.list.index - target < 0) signal = "prev_game";
    }
    if (fe.list.index == target) active = false;
  }

  function nextGame(ttime) {
    if (active) {
      fe.signal(signal);
    }
  }
}
fe.plugin["Sequencer"] <- Sequencer();
