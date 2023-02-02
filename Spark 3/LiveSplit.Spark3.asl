state("Spark the Electric Jester 3") {}

startup
{
	vars.Log = (Action<object>)(output => print("[Spark the Electric Jester 3] " + output));

	if (!File.Exists(@"Components\asl-help"))
	{
		print("No asl-help detected, downloading to Components folder");
		vars.DownloadUnityHelperFunc = (Func<int>)(() =>
		{
			using (var client = new System.Net.WebClient())
			{
				client.DownloadFile("https://github.com/just-ero/asl-help/raw/main/lib/asl-help", @"Components\asl-help");
			}
			return 1;
		});
		vars.DownloadUnityHelperFunc();
		print("Downloaded asl-help");
	}

	Assembly.Load(File.ReadAllBytes(@"Components\asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Spark the Electric Jester 3";
	vars.Helper.LoadSceneManager = true;

	// Start of Settings

	settings.Add("splitResults", true, "Split on every results screen");
	settings.Add("resetOnDelete", true, "Reset timer when you delete the same file you just played on");




	vars.Helper.AlertGameTime();

	vars.GameTime = TimeSpan.FromSeconds(0);
	vars.totalPauseRTA = new TimeSpan(0);
	vars.previousRTA = new TimeSpan(0);
    vars.TotalTime = 0f;
    refreshRate = 60;
}

onStart
{}

onSplit
{}

onReset
{}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
		var save = mono["Save"];
		var SaveFile = mono["SaveFile"];

		var saves = mono.MakeArray<IntPtr>("Save", "Saves");
		var saveSlot = mono.Make<int>("Save", "CurrentSaveSlot");
		//vars.Unity.Make<int>(save.Static, save["CurrentSaveSlot"]).Name = "saveSlot";

		vars.GetCurrentSave = (Func<bool>)(() =>
		{
			saves.Update(game);
			saveSlot.Update(game);
			return vars.Helper.Read<bool>(saves.Current[saveSlot.Current] + SaveFile["SlotInUse"]);
		});

		//vars.Unity.Make<float>(StageTimer.Static, StageTimer["StageTime"]).Name = "stageTime";
		//vars.Unity.Make<bool>(PauseControl.Static, PauseControl["IsPaused"]).Name = "isPaused";

		vars.Helper["stageTime"] = mono.Make<float>("StageTimer", "StageTime");
		vars.Helper["isPaused"] = mono.Make<bool>("PauseCotrol", "IsPaused");

		return true;
	});

	vars.Helper.Load();

	//print(vars.GetCurrentSave().ToString());

	//vars.Unity.Make<bool>(vars.GetCurrentSave(), vars.SaveFile["SlotInUse"]).Name = "slotInUse";
}

update
{
	if (!vars.Helper.Loaded)
		return false;

	vars.Helper.Update();


	//print("Saves Pointer: " + vars.Unity["saves"].Current.ToString());
	//print("Slot number: " + vars.Unity["saveSlot"].Current.ToString());


	current.Scene = vars.Helper.Scenes.Active.Index;
	current.isPaused = vars.Helper["isPaused"].Current;
	current.stageTime = vars.Helper["stageTime"].Current;
	current.SlotInUse = vars.GetCurrentSave();

	//print("Scene Index: " + current.Scene.ToString());

	float deltaTime;
	TimeSpan? rawRTA = timer.CurrentTime.RealTime;
	TimeSpan currentRTA = new TimeSpan(0);
	if (rawRTA.HasValue)
	{
		currentRTA = new TimeSpan(0).Add(rawRTA.Value);
	}

	if (current.isPaused && !((current.Scene >= 3 && current.Scene <= 7) || current.Scene == 0))
    {
        vars.totalPauseRTA = vars.totalPauseRTA.Add(currentRTA-vars.previousRTA);
    }

    deltaTime = current.stageTime - old.stageTime;
    if (deltaTime > 0 && deltaTime < 1)
    {
        vars.TotalTime += deltaTime;
    }

	vars.previousRTA = new TimeSpan(currentRTA.Ticks);
}

start
{
	//vars.Unity.Make<bool>((vars.Unity["saves"].Current)[vars.Unity["saveSlot"].Current], vars.SaveFile["SlotInUse"]).Name = "slotInUse";

	vars.TotalTime = 0f;
	vars.previousRTA = new TimeSpan(0);
	vars.totalPauseRTA = new TimeSpan(0);
	
	if (!old.SlotInUse && current.SlotInUse)
	{
		
		return true;
	}
}

split
{
	if (current.Scene == 87 && old.Scene != 87 && settings["splitResults"])
		return true;
}

reset
{
	if (!current.SlotInUse && old.SlotInUse && settings["resetOnDelete"])
	{
		return true;
	}
}

gameTime
{
	return TimeSpan.FromSeconds(vars.TotalTime) + vars.totalPauseRTA;
}

isLoading
{
	//return current.Scene == -1 || current.Scene == 3 || current.Scene == 4 || vars.Unity.Scenes.Count > 1;
	return true;
}

exit
{
	vars.Helper.Dispose();
}

shutdown
{
	vars.Helper.Dispose();
}
