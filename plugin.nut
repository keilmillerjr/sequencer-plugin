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

    fe.add_ticks_callback(this, "updateTime");
    fe.add_transition_callback(this, "updateSignalTime");
    fe.add_ticks_callback(this, "randomGame");
  }

  function updateTime(ttime) {
    time = ttime;
  }

  function updateSignalTime(ttype, var, ttime) {
    signalTime = time;
    return false;
  }

  function randomGame(ttime) {
    if (ttime >= signalTime + delayTime) fe.signal("random_game");
  }
}
fe.plugin["Sequencer"] <- Sequencer();
