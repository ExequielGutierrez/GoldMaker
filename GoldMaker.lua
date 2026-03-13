-- Gold Maker by Neoraxer (Non-Modular Version)

--== Variables ==--
local GoldMaker_isActive = false;
local GoldMaker_newGold = 0;
local GoldMaker_oldGold = 0;
local GoldMaker_sellAmount = 0;
local GoldMaker_enableInform = true;
local GoldMaker_data = GoldMaker_Data;
local GoldMaker_maxItemsList = 6;
local GoldMaker_itemsPerTic = 1;
local GoldMaker_ticInterval = 1/15;

local iconDefaultPos = {
	point = "TOPRIGHT",
	relativePont = "BOTTOMLEFT",
	relativeTo = "MinimapViewFrame",
	offsetX = -29,
	offsetY = -20,
};

GoldMaker_iconPosition = {};

GoldMaker_userItems = {
	[ 210438 ] = true, -- Test
};

--== Utility Functions ==--

function GoldMaker_IsGold( id )
	return GoldMaker_data[ id ] == true or GoldMaker_userItems[ id ];
end

function GoldMaker_FormatNumber( value )
	return ScoresNormalization( value );
end

function GoldMaker_GetAverage()
	local avg = GoldMaker_newGold / ( GoldMaker_sellAmount > 0 and GoldMaker_sellAmount or 1 );
	return string.format( "%.2f", avg );
end

function GoldMaker_SendMessage( msg )
	DEFAULT_CHAT_FRAME:AddMessage( "|cFFFF8C00Gold Maker:|r |cFFFFFFFF" .. msg );
end

function GoldMaker_PrintResult()
	local lang = GetLanguage();
	local gold = GoldMaker_FormatNumber( GoldMaker_newGold );
	local sold = GoldMaker_FormatNumber( GoldMaker_sellAmount );
	local average = GoldMaker_FormatNumber( GoldMaker_GetAverage() );

	local itemLink = "|Hitem:30d40|h|cffffff42[Gold]|r|h";

	if lang == "ES" then
		GoldMaker_SendMessage( "Has ganado " .. gold .. "x " .. itemLink .. "." );
		GoldMaker_SendMessage( "La venta promedio fue de " .. average .. "x " .. itemLink .. " |cffFFFFFFpor unidad." );
		GoldMaker_SendMessage( "Total vendido: " .. sold .. " piezas." );
	elseif lang == "PL" then
		GoldMaker_SendMessage( "Wygrałeś " .. gold .. "x " .. itemLink .. "." );
		GoldMaker_SendMessage( "Średnia sprzedaż wyniosła " .. average .. "x " .. itemLink .. " |cffFFFFFFza sztukę." );
		GoldMaker_SendMessage( "Łącznie sprzedano: " .. sold .. " sztuk." );
	elseif lang == "DE" then
		GoldMaker_SendMessage( "Du hast " .. gold .. "x " .. itemLink .. " gewonnen." );
		GoldMaker_SendMessage( "Der durchschnittliche Verkauf betrug " .. average .. "x " .. itemLink .. " |cffFFFFFFpro Stück." );
		GoldMaker_SendMessage( "Insgesamt verkauft: " .. sold .. " Stück." );
	elseif lang == "CN" then
		GoldMaker_SendMessage( "你赢得了 " .. gold .. "x " .. itemLink .. "。" );
		GoldMaker_SendMessage( "平均每件出售 " .. average .. "x " .. itemLink .. "。" );
		GoldMaker_SendMessage( "总共售出: " .. sold .. " 件。" );
	elseif lang == "RU" then
		GoldMaker_SendMessage( "Вы выиграли " .. gold .. "x " .. itemLink .. "." );
		GoldMaker_SendMessage( "Средняя продажа составила " .. average .. "x " .. itemLink .. " |cffFFFFFFза штуку." );
		GoldMaker_SendMessage( "Всего продано: " .. sold .. " штук." );
	else
		GoldMaker_SendMessage( "You have won " .. gold .. "x " .. itemLink .. "." );
		GoldMaker_SendMessage( "The average sale was " .. average .. "x " .. itemLink .. " |cffFFFFFFper piece." );
		GoldMaker_SendMessage( "Total sold: " .. sold .. " pieces." );
	end
end

function GoldMaker_PrintNoItems()
	local lang = GetLanguage();

	if lang == "ES" then
		GoldMaker_SendMessage( "|cffFFFFFFNo hay objetos de bajo nivel para vender.|r" );
	elseif lang == "PL" then
		GoldMaker_SendMessage( "|cffFFFFFFBrak przedmiotów niskiego poziomu do sprzedania.|r" );
	elseif lang == "DE" then
		GoldMaker_SendMessage( "|cffFFFFFFKeine niedrigstufigen Gegenstände zum Verkaufen vorhanden.|r" );
	elseif lang == "CN" then
		GoldMaker_SendMessage( "|cffFFFFFF没有低等级物品可供出售。|r" );
	elseif lang == "RU" then
		GoldMaker_SendMessage( "|cffFFFFFFНет низкоуровневых предметов для продажи.|r" );
	else
		GoldMaker_SendMessage( "|cffFFFFFFNo low-level items to sell.|r" );
	end
end

function GoldMaker_PrintADD(link)
	local lang = GetLanguage();

	if lang == "ES" then
		GoldMaker_SendMessage("|cffFFFFFFAgregado " .. link .. " |cffFFFFFFa la venta.");
	elseif lang == "PL" then
		GoldMaker_SendMessage("|cffFFFFFFDodano " .. link .. " |cffFFFFFFdo sprzedaży.");
	elseif lang == "DE" then
		GoldMaker_SendMessage(link .. " |cffFFFFFFzum Verkauf hinzugefügt.");
	elseif lang == "CN" then
		GoldMaker_SendMessage("|cffFFFFFF已将 " .. link .. " |cffFFFFFF添加到出售。");
	elseif lang == "RU" then
		GoldMaker_SendMessage("|cffFFFFFFДобавлен " .. link .. " |cffFFFFFFна продажу.");
	else
		GoldMaker_SendMessage("|cffFFFFFFAdded " .. link .. " |cffFFFFFFfor sale.");
	end
end

function GoldMaker_PrintRemoved(link)
	local lang = GetLanguage();

	if lang == "ES" then
		GoldMaker_SendMessage("|cffFFFFFFSe eliminó " .. link .. " |cffFFFFFFde la venta.");
	elseif lang == "PL" then
		GoldMaker_SendMessage("|cffFFFFFFUsunięto " .. link .. " |cffFFFFFFze sprzedaży.");
	elseif lang == "DE" then
		GoldMaker_SendMessage(link .. " |cffFFFFFFwurde aus dem Verkauf entfernt.");
	elseif lang == "CN" then
		GoldMaker_SendMessage("|cffFFFFFF已将 " .. link .. " |cffFFFFFF从出售中移除。");
	elseif lang == "RU" then
		GoldMaker_SendMessage("|cffFFFFFFУдалён " .. link .. " |cffFFFFFFиз продажи.");
	else
		GoldMaker_SendMessage("|cffFFFFFFRemoved " .. link .. " |cffFFFFFFfrom sale.");
	end
end

--== Core Functions ==--

local GoldMaker_reportDelay = 0.5;

local function GoldMaker_DoReport()
	if GoldMaker_sellAmount == 0 then
		GoldMaker_PrintNoItems();
	elseif GoldMaker_enableInform then
		GoldMaker_newGold = GetPlayerMoney( "copper" ) - GoldMaker_oldGold;
		if GoldMaker_sellAmount < 1 then GoldMaker_sellAmount = 1; end
		GoldMaker_PrintResult();
	end
end

local function GoldMaker_FinishAndReport( close )
	GoldMaker_isActive = false;
	GoldMaker_ClearSellBatchTimers();
	if close and StoreFrame and StoreFrame.IsVisible and StoreFrame:IsVisible() then
		StoreFrame:Hide();
		CloseStore();
	end
	TimerQueue[ "GoldMaker_DelayedReport" ] = {
		GetTime() + GoldMaker_reportDelay,
		function()
			TimerQueue[ "GoldMaker_DelayedReport" ] = nil;
			GoldMaker_DoReport();
		end
	};
end

function GoldMaker_ClearSellBatchTimers()
	local toRemove = {};
	for k in pairs( TimerQueue or {} ) do
		if type( k ) == "string" and ( string.find( k, "GoldMaker_SellBatch" ) or k == "GoldMaker_DelayedReport" ) then
			toRemove[ #toRemove + 1 ] = k;
		end
	end
	for i = 1, #toRemove do
		TimerQueue[ toRemove[ i ] ] = nil;
	end
end

function GoldMaker_SellBatch( close )
	if not StoreFrame or not StoreFrame:IsVisible() then
		GoldMaker_FinishAndReport( false );
		return;
	end
	if ItemMallFrame and ItemMallFrame:IsVisible() then
		GoldMaker_FinishAndReport( false );
		return;
	end

	local soldThisBatch = 0;
	for a = 1, 12 do
		for b = 1, 30 do
			if soldThisBatch >= GoldMaker_itemsPerTic then break; end
			local slot = ( a - 1 ) * 30 + b;
			local index, _, _, itemCount, _, _, itemID = GetBagItemInfo( slot );
			if GoldMaker_IsGold( itemID ) then
				UseBagItem( index );
				soldThisBatch = soldThisBatch + 1;
				GoldMaker_sellAmount = GoldMaker_sellAmount + ( itemCount and itemCount > 1 and itemCount or 1 );
			end
		end
		if soldThisBatch >= GoldMaker_itemsPerTic then break; end
	end

	if soldThisBatch > 0 then
		GoldMaker_batchCounter = ( GoldMaker_batchCounter or 0 ) + 1;
		local key = "GoldMaker_SellBatch_" .. GoldMaker_batchCounter;
		TimerQueue[ key ] = {
			GetTime() + GoldMaker_ticInterval,
			function()
				GoldMaker_SellBatch( close );
			end
		};
	else
		GoldMaker_FinishAndReport( close );
	end
end

function GoldMaker_MakeGold( close )
	GoldMaker_ClearSellBatchTimers();
	GoldMaker_oldGold = GetPlayerMoney( "copper" );
	GoldMaker_sellAmount = 0;

	if StoreFrame:IsVisible() then
		GoldMaker_SellBatch( close );
	else
		GoldMaker_isActive = false;
	end
end

function GoldMaker_OpenStore( close )
	if SpeakFrame:IsVisible() and not StoreFrame:IsVisible() then
		SpeakFrame_Option1_Button.script( 5, 1 );
		if not TimerQueue[ "MakeGold" ] then
			TimerQueue[ "MakeGold" ] = {
				GetTime() + 0.5,
				function() GoldMaker_MakeGold( close ); end
			};
		end
	end
end

function GoldMaker_OnEvent( event )
	if event == "VARIABLES_LOADED" then
		GoldMaker_userItems = GoldMaker_userItems or {};

		if not GoldMaker_iconPosition.point then GoldMaker_iconPosition.point = iconDefaultPos.point; end
		if not GoldMaker_iconPosition.relativePont then GoldMaker_iconPosition.relativePont = iconDefaultPos.relativePont; end
		if not GoldMaker_iconPosition.relativeTo then GoldMaker_iconPosition.relativeTo = iconDefaultPos.relativeTo; end
		if not GoldMaker_iconPosition.offsetX then GoldMaker_iconPosition.offsetX = iconDefaultPos.offsetX; end
		if not GoldMaker_iconPosition.offsetY then GoldMaker_iconPosition.offsetY = iconDefaultPos.offsetY; end

		GoldMaker_Icon_SetPos();
		GoldMaker_UpdateView();
	elseif event == "SHOW_QUESTLIST" or event == "SHOW_REQUESTLIST_DIALOG" then
		if SpeakFrame:IsVisible() then
			local optionText = SpeakFrame_Option1_Button:GetText();
			if TEXT( "AC_ITEMTYPENAME_2" ) == optionText then
				GoldMaker_Sell:Show();
			else
				GoldMaker_Sell:Hide();
			end
		end
	elseif event == "PLAYER_MONEY" then
		if GoldMaker_isActive and ItemMallFrame and ItemMallFrame:IsVisible() then
			GoldMaker_ClearSellBatchTimers();
			GoldMaker_isActive = false;
			if GoldMaker_sellAmount > 0 and GoldMaker_enableInform then
				GoldMaker_newGold = GetPlayerMoney( "copper" ) - GoldMaker_oldGold;
				GoldMaker_PrintResult();
			end
		end
	end
end

--== Entry Points for XML ==--

function GoldMaker_OnOvent( frame, event, arg1, arg2 )
	GoldMaker_OnEvent( event, arg1, arg2 );
end

function GoldMaker_SellButton_OnClick()
	GoldMaker_OpenStore( false );
	GoldMaker_isActive = true;
end

function GoldMaker_SellButton2_OnClick()
	GoldMaker_MakeGold( false );
	GoldMaker_isActive = true;
end

--== Frame Functions ==--

function GoldMaker_UpdateView()
	GoldMaker_UpdateDefaultItems();
	GoldMaker_SetMaxSliderDefault();
	GoldMaker_SetMaxSliderUser();
	GoldMaker_UpdateUserItems();
end

function GoldMaker_OnLoad( this )
	local lang = GetLanguage();
	this:RegisterEvent( "SHOW_QUESTLIST" );
	this:RegisterEvent( "SHOW_REQUESTLIST_DIALOG" );
	this:RegisterEvent( "PLAYER_MONEY" );
	this:RegisterEvent( "VARIABLES_LOADED" );

	SaveVariables( "GoldMaker_iconPosition", "GoldMaker" );
	SaveVariables( "GoldMaker_userItems", "GoldMaker" );

	local orgChatFrameDropDown_Show = ChatFrameDropDown_Show;
	ChatFrameDropDown_Show = function( THIS )
		orgChatFrameDropDown_Show( THIS );
		if UIDROPDOWNMENU_MENU_LEVEL == 1 then

			if ChatFrameDropDown._type ~= "player" and ChatFrameDropDown.id then
				local HexList = {
					[ "quest" ] = true,
					[ "pet" ] = true,
					[ "item" ] = true,
					[ "suit" ] = true,
					[ "phantom" ] = true,
				};
				if HexList[ ChatFrameDropDown._type ] then
					ChatFrameDropDown.id = tonumber( ChatFrameDropDown.id, 16 );
				else
					ChatFrameDropDown.id = tonumber( ChatFrameDropDown.id );
				end

				local id = ChatFrameDropDown.id;
				local ItemType = GetObjectInfo( id, "itemtype" );
				local rare = GetObjectInfo( id, "rare" );

				if (( GetObjectInfo( id, "weapontype" )
					or GetObjectInfo( id, "armortype" )
					or IsRune( id )
					or IsRecipe(id)
					or ( ItemType and ( ItemType == EM_ItemType_Rune or ItemType == EM_ItemType_Ore or ItemType == EM_ItemType_Wood or ItemType == EM_ItemType_Herb )))
					and not IsCard( id ))
					and rare and rare <= 3 then

					local info = {};
					info.isSeparator = 1;
					UIDropDownMenu_AddButton( info, 1 );
					if DropDownList1.numButtons == 1 then
						getglobal( "DropDownList1Button1" ):Hide();
					end

					local info = {};
					info.text = "|cffFFD700Gold Maker|r";
					info.notCheckable = 1;
					info.disabled = 1;
					UIDropDownMenu_AddButton( info, 1 );


					local info = {};
					local text = "";

					if not GoldMaker_userItems[ ChatFrameDropDown.id ] then

						if lang == "ES" then text = "Agregar a la venta";
						elseif lang == "PL" then text = "Dodaj do sprzedaży";
						elseif lang == "DE" then text = "Zum Verkauf hinzufügen";
						elseif lang == "CN" then text = "添加到出售";
						elseif lang == "RU" then text = "Добавить на продажу";
						else text = "Add to Sale"; end

						info.text = "   " .. text;
						info.id = ChatFrameDropDown.id;
						info.notCheckable = 1;
						info.func = function()
							GoldMaker_userItems[ info.id ] = true;
							GoldMaker_UpdateView();
							local rare = GetObjectInfo( info.id, "rare" );
							local Data = ("%x"):format( info.id );
							local Name = TEXT("Sys" .. info.id .. "_name" );
							local R, G, B = GetItemQualityColor( GetObjectInfo( info.id, "rare" ) );
							local Color = ("%02x%02x%02x"):format(R * 255, G * 255, B * 255);
							local ItemLink = CreateHyperlink("item", Data, Name, Color);
							GoldMaker_PrintADD( ItemLink );
						end;
						UIDropDownMenu_AddButton( info, 1 );

					else

						if lang == "ES" then text = "Eliminar de la venta";
						elseif lang == "PL" then text = "Usuń ze sprzedaży";
						elseif lang == "DE" then text = "Vom Verkauf entfernen";
						elseif lang == "CN" then text = "从出售中移除";
						elseif lang == "RU" then text = "Удалить из продажи";
						else text = "Remove from Sale"; end

						info.text = "   " .. text;
						info.id = ChatFrameDropDown.id;
						info.notCheckable = 1;
						info.func = function()
							GoldMaker_userItems[ info.id ] = nil;
							GoldMaker_UpdateView();
							local rare = GetObjectInfo( info.id, "rare" );
							local Data = ("%x"):format( info.id );
							local Name = TEXT("Sys" .. info.id .. "_name" );
							local R, G, B = GetItemQualityColor( GetObjectInfo( info.id, "rare" ) );
							local Color = ("%02x%02x%02x"):format(R * 255, G * 255, B * 255);
							local ItemLink = CreateHyperlink("item", Data, Name, Color);
							GoldMaker_PrintRemoved( ItemLink )
						end;
						UIDropDownMenu_AddButton( info, 1 );
					end
				end
			end
		end
	end;

	UIDropDownMenu_Initialize( ChatFrameDropDown, ChatFrameDropDown_Show, "MENU" );
end

function GoldMaker_OnShow( this )
	GoldMaker_UpdateView();
	UIPanelAnchorFrame_OnShow( this );
end

function GoldMaker_OnMouseDown( this, key )
	UIPanelAnchorFrame_StartMoving( this );
end

function GoldMaker_OnMouseUp( this, key )
	UIPanelAnchorFrame_StopMoving();
end

--== Item List Helpers ==--

local function GoldMaker_GetOrderedItems( tbl )
	local ordered = {};
	for id, status in pairs( tbl or {} ) do
		table.insert( ordered, { id = id, status = status } );
	end
	table.sort( ordered, function( a, b )
		local nameA = TEXT("Sys"..a.id.."_name") or ""
		local nameB = TEXT("Sys"..b.id.."_name") or ""
		return nameA < nameB
	end );
	return ordered;
end

function GoldMaker_UpdateDefaultItems( offset )
	local limit = GoldMaker_maxItemsList or 6;
	local items = GoldMaker_GetOrderedItems( _G.GoldMaker_Data );
	offset = offset or 0;

	for i = 1, limit do
		local data = items[ i + offset ];
		local frame = _G[ "GoldMakerDefaultItem" .. i ];

		if data and frame then
			local name = frame.Title;
			local icon = frame.Icon.Icon;
			local state = frame.Enabled;
			local sysName = TEXT( "Sys" .. data.id .. "_name" );
			local rare = GetObjectInfo( data.id, "rare" );
			local imageid = GetObjectInfo( data.id, "imageid" );

			if imageid then
				local image_dir = GetObjectInfo( imageid, "actfield" );
				icon:SetFile( image_dir );
			end

			name:SetText( sysName );
			name:SetColor( GetItemQualityColor( rare ) );
			state:SetChecked( data.status );
			frame.id = data.id;
			frame:Show();
		elseif frame then
			frame:Hide();
		end
	end
end

function GoldMaker_UpdateUserItems( offset )
	local limit = GoldMaker_maxItemsList or 6;
	local items = GoldMaker_GetOrderedItems( GoldMaker_userItems );

	offset = offset or 0;

	for i = 1, limit do
		local data = items[ i + offset ];
		local frame = _G[ "GoldMakerUserItem" .. i ];

		if data and frame then
			local name = frame.Title;
			local icon = frame.Icon.Icon;
			local state = frame.Enabled;
			local sysName = TEXT( "Sys" .. data.id .. "_name" );
			local rare = GetObjectInfo( data.id, "rare" );
			local imageid = GetObjectInfo( data.id, "imageid" );

			if imageid then
				local image_dir = GetObjectInfo( imageid, "actfield" );
				icon:SetFile( image_dir );
			end

			frame.RemoveButton:Show();
			frame.Title:SetWidth( 83 );

			name:SetText( sysName );
			name:SetColor( GetItemQualityColor( rare ) );
			state:SetChecked( data.status );
			frame.id = data.id;
			frame:Show();
		elseif frame then
			frame:Hide();
		end
	end
end

--== Item Tooltip ==--

function GoldMaker_Item_OnEnter( this )
	this.Background:SetAlphaMode( "ADD" );
	local id = this.id;
	if id then
		if not IsRecipe( id ) then
			GameTooltip:SetItemDB( id );
			GameTooltip:ClearAllAnchors();
			GameTooltip:SetAnchor( "TOPLEFT", "TOPRIGHT", this:GetParent(), 0, -4 );
		else
			local Data = ("%x"):format( id );
			local Name = TEXT("Sys" .. id .. "_name" );
			local R, G, B = GetItemQualityColor( GetObjectInfo( id, "rare" ) );
			local Color = ("%02x%02x%02x"):format(R * 255, G * 255, B * 255);
			local ItemLink = CreateHyperlink("item", Data, Name, Color);
			GameTooltip:SetHyperLink( ItemLink );	
		end
	end
end

function GoldMaker_Item_OnLeave( this )
	this.Background:SetAlphaMode( "BLEND" );
	GameTooltip:Hide();
end

function GoldMaker_Item_OnClic( this, key )
	if key == "LBUTTON"  and IsShiftKeyDown() then
		local id = this.id;
		if id then
			local Data = ("%x"):format( id );
			local Name = TEXT("Sys" .. id .. "_name" );
			local R, G, B = GetItemQualityColor( GetObjectInfo( id, "rare" ) );
			local Color = ("%02x%02x%02x"):format(R * 255, G * 255, B * 255);
			local ItemLink = CreateHyperlink("item", Data, Name, Color);
			if (ChatEdit_AddItemLink(ItemLink)) then return; end
		end
	elseif ( key == "MBUTTON" ) then
		Chat_CopyToClipboard( this.id );
		SendSystemMsg(TEXT("SYS_COPIED_ID"));
	end
end

--== Sliders ==--

function GoldMaker_Slider_DefaultItems_OnValueChange( this )
	local offset = math.floor( this:GetValue() );
	GoldMaker_UpdateDefaultItems( offset );
end

function GoldMaker_Slider_UserItems_OnValueChange( this )
	local offset = math.floor( this:GetValue() );
	GoldMaker_UpdateUserItems( offset );
end

function GoldMaker_SetMaxSliderDefault()
	local function CountGoldMakerData()
		local c = 0;
		for _ in pairs( GoldMaker_Data or {} ) do c = c + 1; end
		return c;
	end
	local slider = GoldMakerDefaultSlider;
	local limit = GoldMaker_maxItemsList or 6;
	slider:SetMaxValue( CountGoldMakerData() - limit );
end

function GoldMaker_SetMaxSliderUser()
	local function CountGoldMakerData()
		local c = 0;
		for _ in pairs( GoldMaker_userItems or {} ) do c = c + 1; end
		return c;
	end
	local slider = GoldMakerUserSlider;
	local limit = GoldMaker_maxItemsList or 6;
	slider:SetMaxValue( CountGoldMakerData() - limit );
end

function GoldMaker_RemoveButtonOnClick( this )
	if GoldMaker_userItems[ this:GetParent().id ] then
		GoldMaker_userItems[ this:GetParent().id ] = nil;
		GoldMaker_UpdateView();
	end
end

--== Icon ==--

function GoldMaker_Icon_SetPos()
	local x = GoldMaker_iconPosition.offsetX or iconDefaultPos.offsetX;
	local y = GoldMaker_iconPosition.offsetY or iconDefaultPos.offsetY;
	GoldMaker_Icon:SetAnchorOffset( x, y );
end

function GoldMaker_Icon_OnMouseDown( this, key )
	if IsShiftKeyDown() and key == "LBUTTON" then
		this:StartMoving();
	end
end

function GoldMaker_Icon_OnMouseUp( this )
	this:StopMovingOrSizing();
	GoldMaker_iconPosition.point, GoldMaker_iconPosition.relativePont,
	GoldMaker_iconPosition.relativeTo, GoldMaker_iconPosition.offsetX,
	GoldMaker_iconPosition.offsetY = this:GetAnchor();
end