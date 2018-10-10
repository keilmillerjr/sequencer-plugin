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

	active = null;
  currentTime = null;
  delayTime = null;
	direction = null;
	insideCount = null;
  outsideCount = null;
  signalTime = null;
  targetIndex = null;

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

    active = false;
    delayTime = config["delayTime"]*1000;
    signalTime = 0;
    time = 0;

    fe.add_ticks_callback(this, "updateTime");
    fe.add_ticks_callback(this, "status");
    fe.add_signal_handler(this, "blockSignals");
    fe.add_transition_callback(this, "updateSignalTime");
  }

	// ----- Ticks Callbacks -----

  function updateTime(ttime) {
    time = ttime;
  }

  function status(ttime) {
    // Activate Sequencer
    if (!active && (ttime >= signalTime + delayTime)) {
			active = true;
			targetIndex = randInt(fe.list.size - 1);
		}

		if (active) {
			insideCount = abs(fe.list.index - targetIndex);
			outsideCount = abs(fe.list.size - insideCount);

			// if difference in between is less than around
      if (insideCount <= outsideCount)
        (targetIndex >= fe.list.index) ? direction = "next" : direction = "prev";
      else
        (fe.list.index >= targetIndex) ? direction = "next" : direction = "prev";

    	// Deactivate or Switch Game
      if (fe.list.index == targetIndex) active = false;
      else switchGame();
    }
  }

	// ----- Signal Handlers -----

  function blockSignals(signal_str) {
    local blocked = null;

    if (active) {
      (direction == "next") ? blocked = "prev_game" : "next_game";
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

	// ----- Transition Callbacks -----

	function updateSignalTime(ttype, var, ttime) {
		signalTime = time;
		return false;
	}

  // ----- Private Functions -----

  function switchGame() {
		if ((insideCount || outsideCount) > 10) {
			(direction == "next") ? fe.list.index += 2 : fe.list.index -= 2;
		}

    fe.signal(direction + "_game");
  }
}
fe.plugin["Sequencer"] <- Sequencer();
