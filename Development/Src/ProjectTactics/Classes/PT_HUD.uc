class PT_HUD extends UDKHUD;

function PostRender()
{
	local PT_PC PC;

	PC = PT_PC(PlayerOwner);

	super.PostRender();
	
	Canvas.DrawColor = class'HUD'.default.WhiteColor;
	Canvas.SetPos(300 / 2, 100 / 2);
	Canvas.DrawText("Exp: "$PC.SaveData.Exp$" Gold "$PC.SaveData.Gold);
}

DefaultProperties
{
}
