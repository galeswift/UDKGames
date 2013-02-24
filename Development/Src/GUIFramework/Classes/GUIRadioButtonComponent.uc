class GUIRadioButtonComponent extends GUICheckButtonComponent;

var() editinline instanced GUIButtonGroup Manager;

// ignore Checkbutton's mousereleased
event MouseReleased(optional byte ButtonNum)
{
    super(GUIInteractiveComponent).MouseReleased(ButtonNum);
}

event MousePressed(optional byte ButtonNum)
{
	if(!bChecked)
	{
		bChecked = True;
		if(Manager != none)
			Manager.SelectionChanged(self);
		OnPropertyChanged(self); // notify about changed checkbox value
	}

	super.MousePressed(ButtonNum);
}

DefaultProperties
{
}
