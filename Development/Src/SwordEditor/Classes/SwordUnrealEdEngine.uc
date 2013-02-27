/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */
class SwordUnrealEdEngine extends UnrealEdEngine
	native;

var IconPage Icons;

struct native TextureSubRegion
{
	var string Name;
	var string SubRegion;
	var int OffsetX;
	var int OffsetY;
	var int SizeX;
	var int SizeY;
};
var config array<TextureSubRegion> TextureRegions;

struct native TextureRegionToDirMap
{
	var string Region;
	var string Directory;
};
var config array<TextureRegionToDirMap> TextureRegionMap;

cpptext
{
	// UEngine interface.
	virtual void Init();

	/**
	 * Callback for when a package gets saved.
	 *
	 * @param	Package - The current package being saved.
	 * @param	bIsSilent - The caller wants non-critical messages suppressed.
	 */
	virtual void PreparePackageForSaving(UPackage* Package, TCHAR* Path, UBOOL bIsSilent);
}

event InitSwordIcons()
{
	Icons = new(self) class'SwordIconsHiRes';
	Icons.Init();
}
