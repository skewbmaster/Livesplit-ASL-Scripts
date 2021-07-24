state("Spark the Electric Jester 3 - Demo")
{
    //float oldigtimer : "mono-2.0-bdwgc.dll", 0x495A68, 0x10, 0x2E0, 0x10, 0x108, 0x28, 0x60, 0x100;
    float igtimer : "mono-2.0-bdwgc.dll", 0x49A0C8, 0x10, 0x1D0, 0x8, 0x4E0, 0x2D8, 0xD0, 0x8, 0x60, 0x8;
    int levelID : "mono-2.0-bdwgc.dll", 0x49A0C8, 0x10, 0x1D0, 0x8, 0x4E0, 0x2B0, 0xD0, 0x8, 0x60, 0xC;
    //byte inShop : "UnityPlayer.dll", 0x19EF1B0, 0x200, 0x148, 0x28, 0x170, 0x910;
}

startup
{
    vars.GameTime = TimeSpan.FromSeconds(0);
    vars.TotalTime = 0f;
    refreshRate = 60;
}

start
{
    vars.TotalTime = 0f;
    //if (current.levelID == 0) 
    {
        //return true;
    }
}

update
{
    float deltaTime = current.igtimer - old.igtimer;

    if (deltaTime > 0 && deltaTime < 1)
    {
        vars.TotalTime += deltaTime;
    }

    
    
}

gameTime
{
    return TimeSpan.FromSeconds(vars.TotalTime);
}

isLoading
{
    return true;
}