state("Spark the Electric Jester 3") {}

startup
{
	vars.Log = (Action<object>)(output => print("[Spark the Electric Jester 3] " + output));

	if (!File.Exists(@"Components\UnityASL.bin"))
	{
		print("No UnityASL detected, downloading to Components folder");
		vars.DownloadUnityHelperFunc = (Func<int>)(() =>
		{
			using (var client = new System.Net.WebClient())
			{
				client.DownloadFile("https://github.com/just-ero/asl-help/raw/main/lib/UnityASL.bin", @"Components\UnityASL.bin");
			}
			return 1;
		});
		vars.DownloadUnityHelperFunc();
		print("Downloaded UnityASL");
	}

	vars.Unity = Assembly.Load(File.ReadAllBytes(@"Components\UnityASL.bin")).CreateInstance("UnityASL.Unity");
	vars.Unity.LoadSceneManager = true;

	if (timer.CurrentTimingMethod == TimingMethod.RealTime)
	{
		var mbox = MessageBox.Show(
			"Spark 3 uses in-game time.\nWould you like to switch to it?",
			"LiveSplit | Spark the Electric Jester 3",
			MessageBoxButtons.YesNo);

		if (mbox == DialogResult.Yes)
			timer.CurrentTimingMethod = TimingMethod.GameTime;
	}

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
	//current.Scene = -1;

	vars.Unity.TryOnLoad = (Func<dynamic, bool>)(helper =>
	{
		var save = helper.GetClass("Assembly-CSharp", "Save");
		vars.SaveFile = helper.GetClass("Assembly-CSharp", "SaveFile");
		var StageTimer = helper.GetClass("Assembly-CSharp", "StageTimer");
		var PauseControl = helper.GetClass("Assembly-CSharp", "PauseCotrol");

		vars.GetCurrentSave = (Func<IntPtr>)(() =>
		{
			var saves = vars.Unity.MakeArray<IntPtr>(save.Static, save["Saves"]);
			int saveSlot = vars.Unity.Make<int>(save.Static, save["CurrentSaveSlot"]);

			return saves[saveSlot];
		});

		vars.Unity.Make<float>(StageTimer.Static, StageTimer["StageTime"]).Name = "stageTime";
		vars.Unity.Make<bool>(PauseControl.Static, PauseControl["IsPaused"]).Name = "isPaused";

		return true;
	});

	vars.Unity.Load(game);

	//vars.Unity.Make<bool>(vars.GetCurrentSave(), vars.SaveFile["SlotInUse"]).Name = "slotInUse";
}

update
{
	if (!vars.Unity.Loaded)
		return false;

	vars.Unity.Update();

	current.Scene = vars.Unity.Scenes.Active.Index;
	//current.SlotInUse = vars.Unity.Make<bool>(vars.GetCurrentSave() + vars.SaveFile["SlotInUse"]);

	float deltaTime;
	TimeSpan? rawRTA = timer.CurrentTime.RealTime;
	TimeSpan currentRTA = new TimeSpan(0);
	if (rawRTA.HasValue)
	{
		currentRTA = new TimeSpan(0).Add(rawRTA.Value);
	}

	if (vars.Unity["isPaused"].Current)
    {
        vars.totalPauseRTA = vars.totalPauseRTA.Add(currentRTA-vars.previousRTA);
    }

    deltaTime = vars.Unity["stageTime"].Current - vars.Unity["stageTime"].Old;
    if (deltaTime > 0 && deltaTime < 1)
    {
        vars.TotalTime += deltaTime;
    }

	vars.previousRTA = new TimeSpan(currentRTA.Ticks);
}

start
{
	vars.TotalTime = 0f;
	vars.previousRTA = new TimeSpan(0);
	vars.totalPauseRTA = new TimeSpan(0);
	
	//return !old.SlotInUse && current.SlotInUse;
}

split
{}

reset
{}

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
	vars.Unity.Reset();
}

shutdown
{
	vars.Unity.Reset();
}
