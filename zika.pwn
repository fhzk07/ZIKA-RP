#include <a_samp>

// ============================================================
// ZK RP MOBILE - BASE REORGANIZADA
// Gamemode SA-MP / open.mp - sem includes externos obrigatorios
// ============================================================

#define COR_VERDE       0x00FF00FF
#define COR_CIANO       0x00E5FFFF
#define COR_VERMELHO    0xFF4444FF
#define COR_BRANCO      0xFFFFFFFF
#define COR_DOURADO     0xFFD700FF
#define COR_ROXO        0x9B5CFFFF
#define COR_PRETO       0x101018EE
#define COR_BOTAO       0x282238EE

// IMPORTANTE: substitua por uma senha NOVA antes de compilar.
#define SENHA_DONO "fhzk333@"
#define NOME_DONO "Fhzk"

#define PAGAMENTO_ENTREGA 250
#define PRECO_ROUPA 500
#define MAX_CASAS 3
#define MAX_MENU_BOTOES 7

#define DIALOG_EMPREGO          1000
#define DIALOG_ROUPAS           1001
#define DIALOG_CONCESSIONARIA   1002
#define DIALOG_DONO_LOGIN       1003
#define DIALOG_DONO_PAINEL      1004
#define DIALOG_DONO_VEICULOS    1005
#define DIALOG_DONO_TELEPORTES  1006
#define DIALOG_CASA             1007
#define DIALOG_PERSONAGEM       1008
#define DIALOG_GPS              1009

#define AGENCIA_X 1477.5
#define AGENCIA_Y -1771.0
#define AGENCIA_Z 18.8
#define ROUPAS_X 2244.3
#define ROUPAS_Y -1665.5
#define ROUPAS_Z 15.5
#define CONCESSIONARIA_X 2131.5
#define CONCESSIONARIA_Y -1150.0
#define CONCESSIONARIA_Z 24.1

#define SKIN_DONO 217

new Text:LogoZK;
new Text:LogoCorte;
new Text:BotaoMenu;
new Text3D:TextoAgencia;
new Actor:FuncionarioEmpregos;

new PlayerText:HUDDinheiro[MAX_PLAYERS];
new PlayerText:HUDVida[MAX_PLAYERS];
new PlayerText:MenuFundo[MAX_PLAYERS];
new PlayerText:MenuTitulo[MAX_PLAYERS];
new PlayerText:MenuBotoes[MAX_PLAYERS][MAX_MENU_BOTOES];
new Text3D:TagDono[MAX_PLAYERS];

new bool:HUDCriado[MAX_PLAYERS];
new bool:MenuCriado[MAX_PLAYERS];
new bool:MenuAberto[MAX_PLAYERS];
new bool:TrabalhandoEntrega[MAX_PLAYERS];
new bool:AdminAutenticado[MAX_PLAYERS];
new bool:CasaComprada[MAX_CASAS];
new bool:CasaTrancada[MAX_CASAS];
new bool:JogadorDentroCasa[MAX_PLAYERS];
new bool:GPSAtivo[MAX_PLAYERS];

new EntregaVeiculo[MAX_PLAYERS];
new EntregaEtapa[MAX_PLAYERS];
new SkinOriginal[MAX_PLAYERS];
new VeiculoConcessionaria[MAX_PLAYERS];
new VeiculoDono[MAX_PLAYERS];
new CasaAtual[MAX_PLAYERS];
new CasaSelecionada[MAX_PLAYERS];
new CasaDono[MAX_CASAS][MAX_PLAYER_NAME];
new Text3D:TextoCasa[MAX_CASAS];

new Float:CasaX[MAX_CASAS] = {2495.0, 2468.0, 2447.0};
new Float:CasaY[MAX_CASAS] = {-1691.2, -1698.0, -1702.0};
new Float:CasaZ[MAX_CASAS] = {13.5, 13.5, 13.5};
new PrecoCasa[MAX_CASAS] = {15000, 25000, 40000};

new Float:EntregaX[3] = {1833.0, 2495.0, 1368.0};
new Float:EntregaY[3] = {-1842.0, -1687.0, -1279.0};
new Float:EntregaZ[3] = {13.5, 13.5, 13.5};

new const SkinLoja[5] = {7, 14, 21, 23, 29};
new const ModeloVeiculo[5] = {462, 468, 560, 541, 400};
new const PrecoVeiculo[5] = {1500, 2500, 8000, 12000, 10000};
new const ModeloDono[5] = {411, 522, 560, 451, 487};

forward AtualizarHUDGeral();

main()
{
    print("ZK RP MOBILE - Gamemode iniciado");
}

stock bool:EhDono(playerid)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    return (strcmp(nome, NOME_DONO, true) == 0);
}

stock bool:EhDonoDaCasa(playerid, casaid)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    return (strcmp(nome, CasaDono[casaid], true) == 0);
}

stock AtualizarHUD(playerid)
{
    if (!IsPlayerConnected(playerid) || !HUDCriado[playerid]) return 1;

    new texto[80];
    new Float:vida, Float:colete;
    format(texto, sizeof(texto), "$ %d", GetPlayerMoney(playerid));
    PlayerTextDrawSetString(playerid, HUDDinheiro[playerid], texto);

    GetPlayerHealth(playerid, vida);
    GetPlayerArmour(playerid, colete);
    format(texto, sizeof(texto), "VIDA %.0f  |  COLETE %.0f", vida, colete);
    PlayerTextDrawSetString(playerid, HUDVida[playerid], texto);
    return 1;
}

public AtualizarHUDGeral()
{
    for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
        if (IsPlayerConnected(playerid)) AtualizarHUD(playerid);
    return 1;
}

stock CriarHUD(playerid)
{
    if (HUDCriado[playerid]) return 1;

    HUDDinheiro[playerid] = CreatePlayerTextDraw(playerid, 505.0, 398.0, "$ 0");
    PlayerTextDrawFont(playerid, HUDDinheiro[playerid], 2);
    PlayerTextDrawLetterSize(playerid, HUDDinheiro[playerid], 0.22, 1.0);
    PlayerTextDrawColor(playerid, HUDDinheiro[playerid], COR_VERDE);
    PlayerTextDrawSetOutline(playerid, HUDDinheiro[playerid], 1);
    PlayerTextDrawSetProportional(playerid, HUDDinheiro[playerid], 1);
    PlayerTextDrawShow(playerid, HUDDinheiro[playerid]);

    HUDVida[playerid] = CreatePlayerTextDraw(playerid, 505.0, 414.0, "VIDA 100 | COLETE 0");
    PlayerTextDrawFont(playerid, HUDVida[playerid], 1);
    PlayerTextDrawLetterSize(playerid, HUDVida[playerid], 0.18, 0.85);
    PlayerTextDrawColor(playerid, HUDVida[playerid], COR_BRANCO);
    PlayerTextDrawSetOutline(playerid, HUDVida[playerid], 1);
    PlayerTextDrawSetProportional(playerid, HUDVida[playerid], 1);
    PlayerTextDrawShow(playerid, HUDVida[playerid]);

    HUDCriado[playerid] = true;
    AtualizarHUD(playerid);
    return 1;
}

stock CriarMenuMobile(playerid)
{
    if (MenuCriado[playerid]) return 1;

    MenuFundo[playerid] = CreatePlayerTextDraw(playerid, 145.0, 100.0, " ");
    PlayerTextDrawFont(playerid, MenuFundo[playerid], 1);
    PlayerTextDrawLetterSize(playerid, MenuFundo[playerid], 0.0, 1.0);
    PlayerTextDrawTextSize(playerid, MenuFundo[playerid], 350.0, 295.0);
    PlayerTextDrawUseBox(playerid, MenuFundo[playerid], 1);
    PlayerTextDrawBoxColor(playerid, MenuFundo[playerid], COR_PRETO);
    PlayerTextDrawSetOutline(playerid, MenuFundo[playerid], 0);
    PlayerTextDrawSetSelectable(playerid, MenuFundo[playerid], 0);

    MenuTitulo[playerid] = CreatePlayerTextDraw(playerid, 175.0, 112.0, "ZK  |  CENTRAL DA CIDADE");
    PlayerTextDrawFont(playerid, MenuTitulo[playerid], 2);
    PlayerTextDrawLetterSize(playerid, MenuTitulo[playerid], 0.28, 1.25);
    PlayerTextDrawColor(playerid, MenuTitulo[playerid], COR_BRANCO);
    PlayerTextDrawSetOutline(playerid, MenuTitulo[playerid], 1);

    new const textos[MAX_MENU_BOTOES][] = {
        "01  |  MEU PERSONAGEM",
        "02  |  EMPREGOS",
        "03  |  GPS / LOCAIS",
        "04  |  LOJA DE ROUPAS",
        "05  |  CONCESSIONARIA",
        "06  |  CASAS",
        "07  |  FECHAR MENU"
    };

    for (new i = 0; i < MAX_MENU_BOTOES; i++)
    {
        MenuBotoes[playerid][i] = CreatePlayerTextDraw(playerid, 175.0, 148.0 + (i * 34.0), textos[i]);
        PlayerTextDrawFont(playerid, MenuBotoes[playerid][i], 1);
        PlayerTextDrawLetterSize(playerid, MenuBotoes[playerid][i], 0.25, 1.1);
        PlayerTextDrawTextSize(playerid, MenuBotoes[playerid][i], 285.0, 25.0);
        PlayerTextDrawColor(playerid, MenuBotoes[playerid][i], COR_BRANCO);
        PlayerTextDrawUseBox(playerid, MenuBotoes[playerid][i], 1);
        PlayerTextDrawBoxColor(playerid, MenuBotoes[playerid][i], COR_BOTAO);
        PlayerTextDrawSetOutline(playerid, MenuBotoes[playerid][i], 0);
        PlayerTextDrawSetSelectable(playerid, MenuBotoes[playerid][i], 1);
    }

    MenuCriado[playerid] = true;
    return 1;
}

stock EsconderMenuMobile(playerid)
{
    if (!MenuCriado[playerid]) return 1;
    PlayerTextDrawHide(playerid, MenuFundo[playerid]);
    PlayerTextDrawHide(playerid, MenuTitulo[playerid]);
    for (new i = 0; i < MAX_MENU_BOTOES; i++)
        PlayerTextDrawHide(playerid, MenuBotoes[playerid][i]);
    MenuAberto[playerid] = false;
    CancelSelectTextDraw(playerid);
    SelectTextDraw(playerid, COR_ROXO);
    return 1;
}

stock MostrarMenuMobile(playerid)
{
    CriarMenuMobile(playerid);
    CancelSelectTextDraw(playerid);
    PlayerTextDrawShow(playerid, MenuFundo[playerid]);
    PlayerTextDrawShow(playerid, MenuTitulo[playerid]);
    for (new i = 0; i < MAX_MENU_BOTOES; i++)
        PlayerTextDrawShow(playerid, MenuBotoes[playerid][i]);
    MenuAberto[playerid] = true;
    SelectTextDraw(playerid, COR_ROXO);
    return 1;
}
stock MostrarPainelDono(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_DONO_PAINEL, DIALOG_STYLE_LIST,
        "{9B5CFF}ZK RP  |  PAINEL DO PROPRIETARIO",
        "Skin exclusiva\nVeiculos especiais\nTeleportes\nAtivar/desativar jetpack\nReceber $100.000\nRestaurar vida e colete\nVoltar ao spawn",
        "Selecionar", "Fechar");
    return 1;
}

stock AtualizarTextoCasa(casaid)
{
    new texto[160];
    if (!CasaComprada[casaid])
        format(texto, sizeof(texto), "{00E5FF}CASA A VENDA\n{FFFFFF}Preco: $%d\n{9B5CFF}Toque ou use /casa", PrecoCasa[casaid]);
    else if (CasaTrancada[casaid])
        format(texto, sizeof(texto), "{FFD700}CASA PARTICULAR\n{FFFFFF}Dono: %s\n{FF4444}PORTA TRANCADA", CasaDono[casaid]);
    else
        format(texto, sizeof(texto), "{FFD700}CASA PARTICULAR\n{FFFFFF}Dono: %s\n{00FF00}PORTA DESTRANCADA", CasaDono[casaid]);
    Update3DTextLabelText(TextoCasa[casaid], COR_CIANO, texto);
    return 1;
}

stock EncontrarCasaProxima(playerid)
{
    for (new i = 0; i < MAX_CASAS; i++)
        if (IsPlayerInRangeOfPoint(playerid, 4.0, CasaX[i], CasaY[i], CasaZ[i])) return i;
    return -1;
}

stock EntrarCasa(playerid, casaid)
{
    if (casaid < 0 || casaid >= MAX_CASAS || !CasaComprada[casaid]) return 1;
    if (CasaTrancada[casaid] && !EhDonoDaCasa(playerid, casaid))
    {
        SendClientMessage(playerid, COR_VERMELHO, "Esta casa esta trancada.");
        return 1;
    }
    if (IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);
    SetPlayerInterior(playerid, 1);
    SetPlayerVirtualWorld(playerid, casaid + 1);
    SetPlayerPos(playerid, 223.0, 1287.0, 1082.1);
    SetPlayerFacingAngle(playerid, 0.0);
    SetCameraBehindPlayer(playerid);
    CasaAtual[playerid] = casaid;
    JogadorDentroCasa[playerid] = true;
    SendClientMessage(playerid, COR_VERDE, "Voce entrou na casa. Use /casa para sair.");
    return 1;
}

stock SairCasa(playerid)
{
    if (!JogadorDentroCasa[playerid] || CasaAtual[playerid] == -1) return 1;
    new casaid = CasaAtual[playerid];
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid, CasaX[casaid] + 1.5, CasaY[casaid], CasaZ[casaid]);
    SetPlayerFacingAngle(playerid, 180.0);
    SetCameraBehindPlayer(playerid);
    CasaAtual[playerid] = -1;
    JogadorDentroCasa[playerid] = false;
    SendClientMessage(playerid, COR_CIANO, "Voce saiu da casa.");
    return 1;
}

stock MostrarMenuCasa(playerid, casaid)
{
    new titulo[64], texto[180];
    CasaSelecionada[playerid] = casaid;
    format(titulo, sizeof(titulo), "{9B5CFF}CASA %d  |  ZK RP", casaid + 1);
    if (!CasaComprada[casaid])
        format(texto, sizeof(texto), "Comprar casa por $%d", PrecoCasa[casaid]);
    else if (EhDonoDaCasa(playerid, casaid))
        format(texto, sizeof(texto), "Entrar na casa\n%s porta", CasaTrancada[casaid] ? "Destrancar" : "Trancar");
    else
        format(texto, sizeof(texto), "Entrar na casa");
    ShowPlayerDialog(playerid, DIALOG_CASA, DIALOG_STYLE_LIST, titulo, texto, "Selecionar", "Fechar");
    return 1;
}

stock MostrarGPS(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST,
        "{9B5CFF}GPS  |  DESTINOS DA CIDADE",
        "Agencia de empregos\nLoja de roupas\nConcessionaria\nCasa 1\nCasa 2\nCasa 3",
        "Marcar rota", "Fechar");
    return 1;
}

stock MostrarEmpregos(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_EMPREGO, DIALOG_STYLE_LIST,
        "{9B5CFF}CENTRAL DE EMPREGOS",
        "Trabalhar como entregador\nEncerrar expediente",
        "Selecionar", "Fechar");
    return 1;
}

stock MostrarLojaRoupas(playerid)
{
    if (!IsPlayerInRangeOfPoint(playerid, 25.0, ROUPAS_X, ROUPAS_Y, ROUPAS_Z))
    {
        SendClientMessage(playerid, COR_CIANO, "Va ate o icone de roupas no mapa para acessar a loja.");
        return 1;
    }
    ShowPlayerDialog(playerid, DIALOG_ROUPAS, DIALOG_STYLE_LIST,
        "{9B5CFF}LOJA DE ROUPAS",
        "Estilo 1 - $500\nEstilo 2 - $500\nEstilo 3 - $500\nEstilo 4 - $500\nEstilo 5 - $500",
        "Comprar", "Fechar");
    return 1;
}

stock MostrarConcessionaria(playerid)
{
    if (!IsPlayerInRangeOfPoint(playerid, 35.0, CONCESSIONARIA_X, CONCESSIONARIA_Y, CONCESSIONARIA_Z))
    {
        SendClientMessage(playerid, COR_CIANO, "Va ate o icone da concessionaria no mapa para comprar um veiculo.");
        return 1;
    }
    ShowPlayerDialog(playerid, DIALOG_CONCESSIONARIA, DIALOG_STYLE_LIST,
        "{9B5CFF}CONCESSIONARIA",
        "Faggio - $1.500\nSanchez - $2.500\nElegy - $8.000\nBullet - $12.000\nLandstalker - $10.000",
        "Comprar", "Fechar");
    return 1;
}

stock IniciarEntrega(playerid)
{
    if (TrabalhandoEntrega[playerid])
    {
        SendClientMessage(playerid, COR_VERMELHO, "Voce ja esta trabalhando.");
        return 1;
    }
    if (IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    EntregaVeiculo[playerid] = CreateVehicle(448,
        x + (2.5 * floatsin(-a, degrees)),
        y + (2.5 * floatcos(-a, degrees)), z, a, -1, -1, -1);
    if (EntregaVeiculo[playerid] == INVALID_VEHICLE_ID)
    {
        SendClientMessage(playerid, COR_VERMELHO, "Nao foi possivel criar a moto de entrega.");
        return 1;
    }
    SkinOriginal[playerid] = GetPlayerSkin(playerid);
    SetPlayerSkin(playerid, 155);
    TrabalhandoEntrega[playerid] = true;
    EntregaEtapa[playerid] = 0;
    PutPlayerInVehicle(playerid, EntregaVeiculo[playerid], 0);
    SetPlayerRaceCheckpoint(playerid, 0, EntregaX[0], EntregaY[0], EntregaZ[0],
        EntregaX[1], EntregaY[1], EntregaZ[1], 5.0);
    SendClientMessage(playerid, COR_VERDE, "Expediente iniciado! Siga o checkpoint no mapa. Cada entrega paga $250.");
    return 1;
}

stock PararEntrega(playerid)
{
    if (!TrabalhandoEntrega[playerid])
    {
        SendClientMessage(playerid, COR_VERMELHO, "Voce nao esta trabalhando.");
        return 1;
    }
    DisablePlayerRaceCheckpoint(playerid);
    if (IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleID(playerid) == EntregaVeiculo[playerid])
        RemovePlayerFromVehicle(playerid);
    if (EntregaVeiculo[playerid] != INVALID_VEHICLE_ID)
        DestroyVehicle(EntregaVeiculo[playerid]);
    EntregaVeiculo[playerid] = INVALID_VEHICLE_ID;
    TrabalhandoEntrega[playerid] = false;
    EntregaEtapa[playerid] = 0;
    if (IsPlayerConnected(playerid)) SetPlayerSkin(playerid, SkinOriginal[playerid]);
    SendClientMessage(playerid, COR_CIANO, "Expediente encerrado. Sua roupa anterior foi restaurada.");
    return 1;
}

stock TeleportarSeguro(playerid, Float:x, Float:y, Float:z, Float:angulo)
{
    if (GPSAtivo[playerid])
    {
        DisablePlayerCheckpoint(playerid);
        GPSAtivo[playerid] = false;
    }
    if (IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerVelocity(playerid, 0.0, 0.0, 0.0);
    SetPlayerPos(playerid, x, y, z);
    SetPlayerFacingAngle(playerid, angulo);
    SetCameraBehindPlayer(playerid);
    return 1;
}

stock AbrirMenuPersonagem(playerid)
{
    new nome[MAX_PLAYER_NAME], texto[180];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(texto, sizeof(texto), "Nome: %s\nDinheiro: $%d\nNivel: %d\nProfissao: %s",
        nome, GetPlayerMoney(playerid), GetPlayerScore(playerid),
        TrabalhandoEntrega[playerid] ? "Entregador" : "Desempregado");
    ShowPlayerDialog(playerid, DIALOG_PERSONAGEM, DIALOG_STYLE_MSGBOX,
        "{9B5CFF}MEU PERSONAGEM", texto, "Atualizar", "Fechar");
    return 1;
}
public OnGameModeInit()
{
    SetGameModeText("ZK RP | Mobile Roleplay");
    AddPlayerClass(0, 1481.0, -1771.0, 18.8, 90.0, 0, 0, 0, 0, 0, 0);
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    ShowNameTags(true);
    UsePlayerPedAnims();
    SetWorldTime(12);
    SetWeather(1);

    // Marca ZK: letras brancas com corte roxo central.
    LogoZK = TextDrawCreate(320.0, 10.0, "ZK");
    TextDrawAlignment(LogoZK, 2);
    TextDrawLetterSize(LogoZK, 0.48, 1.8);
    TextDrawColor(LogoZK, COR_BRANCO);
    TextDrawSetOutline(LogoZK, 0);
    TextDrawSetShadow(LogoZK, 0);
    TextDrawFont(LogoZK, 2);
    TextDrawSetProportional(LogoZK, 1);

    LogoCorte = TextDrawCreate(320.0, 10.0, "/");
    TextDrawAlignment(LogoCorte, 2);
    TextDrawLetterSize(LogoCorte, 0.48, 1.8);
    TextDrawColor(LogoCorte, COR_ROXO);
    TextDrawSetOutline(LogoCorte, 0);
    TextDrawSetShadow(LogoCorte, 0);
    TextDrawFont(LogoCorte, 2);
    TextDrawSetProportional(LogoCorte, 1);

    BotaoMenu = TextDrawCreate(18.0, 350.0, "MENU");
    TextDrawLetterSize(BotaoMenu, 0.32, 1.45);
    TextDrawTextSize(BotaoMenu, 105.0, 34.0);
    TextDrawAlignment(BotaoMenu, 1);
    TextDrawColor(BotaoMenu, COR_BRANCO);
    TextDrawUseBox(BotaoMenu, 1);
    TextDrawBoxColor(BotaoMenu, COR_ROXO);
    TextDrawSetOutline(BotaoMenu, 0);
    TextDrawSetSelectable(BotaoMenu, 1);
    TextDrawFont(BotaoMenu, 1);

    FuncionarioEmpregos = CreateActor(17, AGENCIA_X, AGENCIA_Y, AGENCIA_Z, 180.0);
    TextoAgencia = Create3DTextLabel("{9B5CFF}CENTRAL DE EMPREGOS\n{FFFFFF}Acesse pelo MENU",
        COR_CIANO, AGENCIA_X, AGENCIA_Y, AGENCIA_Z + 1.0, 15.0, 0, 0);

    for (new i = 0; i < MAX_CASAS; i++)
    {
        CasaComprada[i] = false;
        CasaTrancada[i] = false;
        CasaDono[i][0] = '\0';
        TextoCasa[i] = Create3DTextLabel("CASA A VENDA", COR_CIANO,
            CasaX[i], CasaY[i], CasaZ[i] + 1.0, 15.0, 0, 0);
        AtualizarTextoCasa(i);
    }
    SetTimer("AtualizarHUDGeral", 1000, true);
    return 1;
}

public OnGameModeExit()
{
    TextDrawDestroy(LogoZK);
    TextDrawDestroy(LogoCorte);
    TextDrawDestroy(BotaoMenu);
    Delete3DTextLabel(TextoAgencia);
    for (new i = 0; i < MAX_CASAS; i++) Delete3DTextLabel(TextoCasa[i]);
    if (FuncionarioEmpregos != INVALID_ACTOR_ID) DestroyActor(FuncionarioEmpregos);
    return 1;
}

public OnPlayerConnect(playerid)
{
    TrabalhandoEntrega[playerid] = false;
    AdminAutenticado[playerid] = false;
    EntregaVeiculo[playerid] = INVALID_VEHICLE_ID;
    VeiculoConcessionaria[playerid] = INVALID_VEHICLE_ID;
    VeiculoDono[playerid] = INVALID_VEHICLE_ID;
    EntregaEtapa[playerid] = 0;
    CasaAtual[playerid] = -1;
    CasaSelecionada[playerid] = -1;
    JogadorDentroCasa[playerid] = false;
    GPSAtivo[playerid] = false;
    HUDCriado[playerid] = false;
    MenuCriado[playerid] = false;
    MenuAberto[playerid] = false;
    TagDono[playerid] = Text3D:INVALID_3DTEXT_ID;

    CriarHUD(playerid);
    CriarMenuMobile(playerid);

    // Icones globais dos pontos importantes da cidade.
    // Icone 0 e um marcador colorido seguro; o ID 56 pode causar crash ao abrir a legenda do mapa.
    SetPlayerMapIcon(playerid, 1, AGENCIA_X, AGENCIA_Y, AGENCIA_Z, 0, COR_CIANO, MAPICON_GLOBAL);
    SetPlayerMapIcon(playerid, 2, ROUPAS_X, ROUPAS_Y, ROUPAS_Z, 45, 0, MAPICON_GLOBAL);
    SetPlayerMapIcon(playerid, 3, CONCESSIONARIA_X, CONCESSIONARIA_Y, CONCESSIONARIA_Z, 0, COR_ROXO, MAPICON_GLOBAL);
    for (new i = 0; i < MAX_CASAS; i++)
        SetPlayerMapIcon(playerid, 10 + i, CasaX[i], CasaY[i], CasaZ[i], CasaComprada[i] ? 32 : 31, 0, MAPICON_GLOBAL);

    if (EhDono(playerid))
    {
        TagDono[playerid] = Create3DTextLabel("{FFD700}[DONO]\n{FFFFFF}Fhzk", COR_DOURADO,
            0.0, 0.0, 0.0, 30.0, 0, 1);
        Attach3DTextLabelToPlayer(TagDono[playerid], playerid, 0.0, 0.0, 0.45);
        SendClientMessage(playerid, COR_DOURADO, "Acesso de proprietario detectado. Use /dono para autenticar.");
    }
    SendClientMessage(playerid, COR_ROXO, "Bem-vindo ao ZK RP Mobile!");
    SendClientMessage(playerid, COR_BRANCO, "Toque no botao MENU para abrir a central da cidade.");
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if (GPSAtivo[playerid]) DisablePlayerCheckpoint(playerid);
    GPSAtivo[playerid] = false;
    if (TrabalhandoEntrega[playerid]) PararEntrega(playerid);
    if (EntregaVeiculo[playerid] != INVALID_VEHICLE_ID) DestroyVehicle(EntregaVeiculo[playerid]);
    if (VeiculoConcessionaria[playerid] != INVALID_VEHICLE_ID) DestroyVehicle(VeiculoConcessionaria[playerid]);
    if (VeiculoDono[playerid] != INVALID_VEHICLE_ID) DestroyVehicle(VeiculoDono[playerid]);
    if (TagDono[playerid] != Text3D:INVALID_3DTEXT_ID) Delete3DTextLabel(TagDono[playerid]);

    if (HUDCriado[playerid])
    {
        PlayerTextDrawDestroy(playerid, HUDDinheiro[playerid]);
        PlayerTextDrawDestroy(playerid, HUDVida[playerid]);
    }
    if (MenuCriado[playerid])
    {
        PlayerTextDrawDestroy(playerid, MenuFundo[playerid]);
        PlayerTextDrawDestroy(playerid, MenuTitulo[playerid]);
        for (new i = 0; i < MAX_MENU_BOTOES; i++) PlayerTextDrawDestroy(playerid, MenuBotoes[playerid][i]);
    }
    return 1;
}

public OnPlayerSpawn(playerid)
{
    if (GPSAtivo[playerid]) DisablePlayerCheckpoint(playerid);
    GPSAtivo[playerid] = false;
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    CasaAtual[playerid] = -1;
    JogadorDentroCasa[playerid] = false;
    TeleportarSeguro(playerid, 1481.0, -1771.0, 18.8, 90.0);
    TextDrawShowForPlayer(playerid, LogoZK);
    TextDrawShowForPlayer(playerid, LogoCorte);
    TextDrawShowForPlayer(playerid, BotaoMenu);
    if (EhDono(playerid))
    {
        SetPlayerSkin(playerid, SKIN_DONO);
        SetPlayerColor(playerid, COR_DOURADO);
    }
    if (HUDCriado[playerid])
    {
        PlayerTextDrawShow(playerid, HUDDinheiro[playerid]);
        PlayerTextDrawShow(playerid, HUDVida[playerid]);
    }
    SelectTextDraw(playerid, COR_ROXO);
    AtualizarHUD(playerid);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if (GPSAtivo[playerid]) DisablePlayerCheckpoint(playerid);
    GPSAtivo[playerid] = false;
    if (TrabalhandoEntrega[playerid]) PararEntrega(playerid);
    if (JogadorDentroCasa[playerid])
    {
        JogadorDentroCasa[playerid] = false;
        CasaAtual[playerid] = -1;
    }
    return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if (clickedid == BotaoMenu)
    {
        MostrarMenuMobile(playerid);
        return 1;
    }
    return 0;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if (!MenuAberto[playerid]) return 0;
    for (new i = 0; i < MAX_MENU_BOTOES; i++)
    {
        if (playertextid == MenuBotoes[playerid][i])
        {
            EsconderMenuMobile(playerid);
            switch (i)
            {
                case 0: AbrirMenuPersonagem(playerid);
                case 1: MostrarEmpregos(playerid);
                case 2: MostrarGPS(playerid);
                case 3: MostrarLojaRoupas(playerid);
                case 4: MostrarConcessionaria(playerid);
                case 5:
                {
                    if (JogadorDentroCasa[playerid]) SairCasa(playerid);
                    else
                    {
                        new casa = EncontrarCasaProxima(playerid);
                        if (casa == -1) SendClientMessage(playerid, COR_CIANO, "Aproxime-se de uma casa marcada no mapa.");
                        else MostrarMenuCasa(playerid, casa);
                    }
                }
                case 6: return 1;
            }
            return 1;
        }
    }
    return 0;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (dialogid == DIALOG_PERSONAGEM)
    {
        if (response) AbrirMenuPersonagem(playerid);
        return 1;
    }
    if (dialogid == DIALOG_GPS)
    {
        if (!response) return 1;
        GPSAtivo[playerid] = true;
        switch (listitem)
        {
            case 0: SetPlayerCheckpoint(playerid, AGENCIA_X, AGENCIA_Y, AGENCIA_Z, 4.0);
            case 1: SetPlayerCheckpoint(playerid, ROUPAS_X, ROUPAS_Y, ROUPAS_Z, 4.0);
            case 2: SetPlayerCheckpoint(playerid, CONCESSIONARIA_X, CONCESSIONARIA_Y, CONCESSIONARIA_Z, 4.0);
            case 3: SetPlayerCheckpoint(playerid, CasaX[0], CasaY[0], CasaZ[0], 4.0);
            case 4: SetPlayerCheckpoint(playerid, CasaX[1], CasaY[1], CasaZ[1], 4.0);
            case 5: SetPlayerCheckpoint(playerid, CasaX[2], CasaY[2], CasaZ[2], 4.0);
            default: GPSAtivo[playerid] = false;
        }
        if (GPSAtivo[playerid]) SendClientMessage(playerid, COR_VERDE, "GPS marcado! Siga o checkpoint no mapa.");
        return 1;
    }
    if (dialogid == DIALOG_EMPREGO)
    {
        if (response)
        {
            if (listitem == 0) IniciarEntrega(playerid);
            else if (listitem == 1) PararEntrega(playerid);
        }
        return 1;
    }
    if (dialogid == DIALOG_ROUPAS)
    {
        if (!response) return 1;
        if (listitem < 0 || listitem >= 5) return 1;
        if (GetPlayerMoney(playerid) < PRECO_ROUPA)
        {
            SendClientMessage(playerid, COR_VERMELHO, "Dinheiro insuficiente.");
            return 1;
        }
        GivePlayerMoney(playerid, -PRECO_ROUPA);
        SetPlayerSkin(playerid, SkinLoja[listitem]);
        SendClientMessage(playerid, COR_VERDE, "Roupa comprada e equipada.");
        AtualizarHUD(playerid);
        return 1;
    }
    if (dialogid == DIALOG_CONCESSIONARIA)
    {
        if (!response) return 1;
        if (listitem < 0 || listitem >= 5) return 1;
        if (GetPlayerMoney(playerid) < PrecoVeiculo[listitem])
        {
            SendClientMessage(playerid, COR_VERMELHO, "Dinheiro insuficiente.");
            return 1;
        }
        GivePlayerMoney(playerid, -PrecoVeiculo[listitem]);
        if (VeiculoConcessionaria[playerid] != INVALID_VEHICLE_ID)
            DestroyVehicle(VeiculoConcessionaria[playerid]);
        VeiculoConcessionaria[playerid] = CreateVehicle(ModeloVeiculo[listitem],
            CONCESSIONARIA_X + 5.0, CONCESSIONARIA_Y, CONCESSIONARIA_Z, 90.0, -1, -1, -1);
        if (VeiculoConcessionaria[playerid] == INVALID_VEHICLE_ID)
        {
            GivePlayerMoney(playerid, PrecoVeiculo[listitem]);
            SendClientMessage(playerid, COR_VERMELHO, "Falha ao criar veiculo. Dinheiro devolvido.");
            return 1;
        }
        PutPlayerInVehicle(playerid, VeiculoConcessionaria[playerid], 0);
        SendClientMessage(playerid, COR_VERDE, "Veiculo comprado! Este sistema ainda nao salva a propriedade apos reiniciar.");
        AtualizarHUD(playerid);
        return 1;
    }
    if (dialogid == DIALOG_CASA)
    {
        if (!response) return 1;
        new casa = CasaSelecionada[playerid];
        if (casa < 0 || casa >= MAX_CASAS) return 1;
        if (!CasaComprada[casa])
        {
            if (GetPlayerMoney(playerid) < PrecoCasa[casa])
            {
                SendClientMessage(playerid, COR_VERMELHO, "Dinheiro insuficiente para comprar esta casa.");
                return 1;
            }
            GivePlayerMoney(playerid, -PrecoCasa[casa]);
            CasaComprada[casa] = true;
            CasaTrancada[casa] = false;
            GetPlayerName(playerid, CasaDono[casa], MAX_PLAYER_NAME);
            AtualizarTextoCasa(casa);
            for (new p = 0; p < MAX_PLAYERS; p++)
                if (IsPlayerConnected(p)) SetPlayerMapIcon(p, 10 + casa, CasaX[casa], CasaY[casa], CasaZ[casa], 32, 0, MAPICON_GLOBAL);
            SendClientMessage(playerid, COR_VERDE, "Casa comprada! A propriedade ainda nao e salva apos reiniciar o servidor.");
            AtualizarHUD(playerid);
        }
        else if (EhDonoDaCasa(playerid, casa))
        {
            if (listitem == 0) EntrarCasa(playerid, casa);
            else if (listitem == 1)
            {
                CasaTrancada[casa] = !CasaTrancada[casa];
                AtualizarTextoCasa(casa);
                SendClientMessage(playerid, COR_VERDE, CasaTrancada[casa] ? "Casa trancada." : "Casa destrancada.");
            }
        }
        else if (listitem == 0) EntrarCasa(playerid, casa);
        return 1;
    }
    if (dialogid == DIALOG_DONO_LOGIN)
    {
        if (!response) return 1;
        if (!EhDono(playerid)) return 1;
        if (strcmp(inputtext, SENHA_DONO, false) != 0)
        {
            AdminAutenticado[playerid] = false;
            SendClientMessage(playerid, COR_VERMELHO, "Senha incorreta.");
            return 1;
        }
        AdminAutenticado[playerid] = true;
        SendClientMessage(playerid, COR_DOURADO, "Acesso de proprietario autorizado.");
        MostrarPainelDono(playerid);
        return 1;
    }
    if (dialogid == DIALOG_DONO_PAINEL)
    {
        if (!response || !EhDono(playerid) || !AdminAutenticado[playerid]) return 1;
        switch (listitem)
        {
            case 0: SetPlayerSkin(playerid, SKIN_DONO);
            case 1: ShowPlayerDialog(playerid, DIALOG_DONO_VEICULOS, DIALOG_STYLE_LIST,
                "{FFD700}VEICULOS EXCLUSIVOS", "Infernus\nNRG-500\nSultan\nTurismo\nMaverick", "Pegar", "Voltar");
            case 2: ShowPlayerDialog(playerid, DIALOG_DONO_TELEPORTES, DIALOG_STYLE_LIST,
                "{FFD700}TELEPORTES", "Prefeitura / Spawn\nAeroporto\nPraia Santa Maria\nSan Fierro\nLas Venturas", "Ir", "Voltar");
            case 3:
            {
                if (GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK)
                    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
                else SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
                MostrarPainelDono(playerid);
            }
            case 4:
            {
                GivePlayerMoney(playerid, 100000);
                AtualizarHUD(playerid);
                MostrarPainelDono(playerid);
            }
            case 5:
            {
                SetPlayerHealth(playerid, 100.0);
                SetPlayerArmour(playerid, 100.0);
                AtualizarHUD(playerid);
                MostrarPainelDono(playerid);
            }
            case 6: TeleportarSeguro(playerid, 1481.0, -1771.0, 18.8, 90.0);
        }
        return 1;
    }
    if (dialogid == DIALOG_DONO_VEICULOS)
    {
        if (!EhDono(playerid) || !AdminAutenticado[playerid]) return 1;
        if (!response) { MostrarPainelDono(playerid); return 1; }
        if (listitem < 0 || listitem >= 5) return 1;
        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
        if (IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);
        if (VeiculoDono[playerid] != INVALID_VEHICLE_ID) DestroyVehicle(VeiculoDono[playerid]);
        VeiculoDono[playerid] = CreateVehicle(ModeloDono[listitem], x + 3.0, y, z, a, 0, 0, -1);
        if (VeiculoDono[playerid] != INVALID_VEHICLE_ID) PutPlayerInVehicle(playerid, VeiculoDono[playerid], 0);
        MostrarPainelDono(playerid);
        return 1;
    }
    if (dialogid == DIALOG_DONO_TELEPORTES)
    {
        if (!EhDono(playerid) || !AdminAutenticado[playerid]) return 1;
        if (!response) { MostrarPainelDono(playerid); return 1; }
        switch (listitem)
        {
            case 0: TeleportarSeguro(playerid, 1481.0, -1771.0, 18.8, 90.0);
            case 1: TeleportarSeguro(playerid, 1958.0, -2185.0, 13.5, 90.0);
            case 2: TeleportarSeguro(playerid, 342.0, -1808.0, 5.0, 90.0);
            case 3: TeleportarSeguro(playerid, -1985.0, 137.0, 27.7, 90.0);
            case 4: TeleportarSeguro(playerid, 1690.0, 1447.0, 10.7, 90.0);
        }
        return 1;
    }
    return 0;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if (GPSAtivo[playerid])
    {
        GPSAtivo[playerid] = false;
        DisablePlayerCheckpoint(playerid);
        SendClientMessage(playerid, COR_VERDE, "Voce chegou ao destino marcado no GPS.");
    }
    return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
    if (!TrabalhandoEntrega[playerid]) return 1;
    if (GetPlayerVehicleID(playerid) != EntregaVeiculo[playerid]) return 1;
    GivePlayerMoney(playerid, PAGAMENTO_ENTREGA);
    SendClientMessage(playerid, COR_VERDE, "Entrega concluida! Voce recebeu $250.");
    EntregaEtapa[playerid]++;
    if (EntregaEtapa[playerid] >= 3) EntregaEtapa[playerid] = 0;
    new proxima = EntregaEtapa[playerid];
    new seguinte = proxima + 1;
    if (seguinte >= 3) seguinte = 0;
    SetPlayerRaceCheckpoint(playerid, 0,
        EntregaX[proxima], EntregaY[proxima], EntregaZ[proxima],
        EntregaX[seguinte], EntregaY[seguinte], EntregaZ[seguinte], 5.0);
    AtualizarHUD(playerid);
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if (JogadorDentroCasa[playerid] && (newkeys & KEY_SECONDARY_ATTACK)) SairCasa(playerid);
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!strcmp(cmdtext, "/menu", true)) { MostrarMenuMobile(playerid); return 1; }
    if (!strcmp(cmdtext, "/parar", true)) { PararEntrega(playerid); return 1; }
    if (!strcmp(cmdtext, "/casa", true))
    {
        if (JogadorDentroCasa[playerid]) { SairCasa(playerid); return 1; }
        new casa = EncontrarCasaProxima(playerid);
        if (casa == -1) SendClientMessage(playerid, COR_VERMELHO, "Aproxime-se de uma casa marcada no mapa.");
        else MostrarMenuCasa(playerid, casa);
        return 1;
    }
    if (!strcmp(cmdtext, "/empregos", true)) { MostrarEmpregos(playerid); return 1; }
    if (!strcmp(cmdtext, "/gps", true)) { MostrarGPS(playerid); return 1; }
    if (!strcmp(cmdtext, "/roupas", true)) { MostrarLojaRoupas(playerid); return 1; }
    if (!strcmp(cmdtext, "/concessionaria", true)) { MostrarConcessionaria(playerid); return 1; }
    if (!strcmp(cmdtext, "/dono", true))
    {
        if (!EhDono(playerid)) { SendClientMessage(playerid, COR_VERMELHO, "Acesso negado."); return 1; }
        if (AdminAutenticado[playerid]) MostrarPainelDono(playerid);
        else ShowPlayerDialog(playerid, DIALOG_DONO_LOGIN, DIALOG_STYLE_PASSWORD,
            "{FFD700}ACESSO DO PROPRIETARIO", "Digite sua senha particular:", "Entrar", "Cancelar");
        return 1;
    }
    if (!strcmp(cmdtext, "/ajuda", true))
    {
        SendClientMessage(playerid, COR_ROXO, "ZK RP: use o botao MENU para acessar os sistemas.");
        SendClientMessage(playerid, COR_BRANCO, "Atalhos: /menu /casa /parar /dono");
        return 1;
    }
    return 0;
}