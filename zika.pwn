#include <a_samp>

// ============================================================================
// ZK RP v3.0 - GAMEMODE MOBILE COMPLETO (NATIVO - ZERO DEPENDENCIAS)
// Pastas obrigatorias em scriptfiles: "Contas" e "Dados"
// ============================================================================

// --- CORES ---
#define COR_BRANCO       0xFFFFFFFF
#define COR_PRETO        0x101018FF
#define COR_ROXO         0x9B59B6FF
#define COR_ROXO_CLARO   0xC39BD3FF
#define COR_VERDE        0x2ECC71FF
#define COR_VERMELHO     0xE74C3CFF
#define COR_CINZA        0xBDC3C7FF
#define COR_DOURADO      0xF1C40FFF
#define COR_AZUL         0x3498DBFF
#define COR_LARANJA      0xE67E22FF
#define COR_CIANO        0x1ABC9CFF

// --- CONFIGURACOES GERAIS ---
#define SENHA_DONO              "fhzk333@"
#define NOME_DONO               "Fhzk"
#define TEMPO_PAYDAY_MINUTOS    20
#define TEMPO_FOME_SEGUNDOS     150
#define PRECO_CNH               1200
#define PRECO_ROUPA             500
#define PRECO_LITRO_GASOLINA    5
#define PRECO_REPARO_VEICULO    350
#define MAX_CASAS               6
#define MAX_VEICULOS_SERVIDOR   2000

// --- DIALOGS ---
enum {
    DIALOG_LOGIN = 1000,
    DIALOG_REGISTRO,
    DIALOG_MENU_PRINCIPAL,
    DIALOG_RG_STATS,
    DIALOG_INVENTARIO,
    DIALOG_GPS,
    DIALOG_EMPREGOS,
    DIALOG_BANCO,
    DIALOG_BANCO_DEPOSITAR,
    DIALOG_BANCO_SACAR,
    DIALOG_BANCO_TRANSFERIR_ID,
    DIALOG_BANCO_TRANSFERIR_VALOR,
    DIALOG_PREFEITURA,
    DIALOG_ROUPAS,
    DIALOG_CONCESSIONARIA,
    DIALOG_VEICULO_MENU,
    DIALOG_CASA,
    DIALOG_LOJA_247,
    DIALOG_POSTO,
    DIALOG_POLICIA,
    DIALOG_FACCAO,
    DIALOG_CELULAR,
    DIALOG_CELULAR_SMS_ID,
    DIALOG_CELULAR_SMS_TXT,
    DIALOG_CELULAR_ANUNCIO,
    DIALOG_DONO_LOGIN,
    DIALOG_DONO_PAINEL,
    DIALOG_DONO_VEICULOS,
    DIALOG_DONO_TELEPORTES,
    DIALOG_DONO_EVENTO
};

// --- TEXTDRAWS GLOBAIS ---
new Text:LogoZK;
new Text:LogoRP;
new Text:BtnMenu;
new Text:BtnInteragir;
new Text:BtnVeiculo;
new Text:BtnGPS;
new Text:BtnCelular;

// --- DADOS DO JOGADOR ---
enum E_PLAYER_DATA {
    pSenha[32],
    bool:pLogado,
    bool:pEhDono,
    bool:pAutenticadoDono,
    pDinheiro,
    pBanco,
    pNivel,
    pXP,
    pSkin,
    pFome,
    pSede,
    pCNH,
    pEmprego,       // 0 = Desempregado, 1 = iFood, 2 = Onibus, 3 = Policia, 4 = Mecanico
    pFaccao,        // 0 = Civil, 1 = Tropa ZK (Crime)
    pDrogas,        // Quantidade de pacotes de droga
    pKitMedico,     // Quantidade de kits
    pComida,        // Quantidade de lanches
    pAgua,          // Quantidade de aguas
    pProcurado,
    pMinutosJogados,
    pAlvoTransferencia,
    pAlvoSMS,
    // Veiculo Pessoal
    pVehModelo,
    pVehCor1,
    pVehCor2,
    pVehID,
    bool:pVehSpawnado,
    bool:pVehTrancado,
    // Trabalho & Temporarios
    bool:pTrabalhando,
    pVehTrabalho,
    pEtapaTrabalho,
    bool:pDentroCasa,
    pCasaAtual,
    pUltimoAnuncio
};
new PlayerInfo[MAX_PLAYERS][E_PLAYER_DATA];

// --- COMBUSTIVEL POR VEICULO ---
new CombustivelVeh[MAX_VEICULOS_SERVIDOR];
new bool:MotorLigadoVeh[MAX_VEICULOS_SERVIDOR];

// --- HUD INDIVIDUAL ---
new PlayerText:HUDInfo[MAX_PLAYERS];
new PlayerText:HUDStatus[MAX_PLAYERS];
new PlayerText:HUDVelocimetro[MAX_PLAYERS];
new bool:HUDCriado[MAX_PLAYERS];
new bool:VelocimetroVisivel[MAX_PLAYERS];

// --- CASAS ---
enum E_CASA_DATA {
    cDono[MAX_PLAYER_NAME],
    bool:cComprada,
    bool:cTrancada,
    cPreco,
    Float:cX,
    Float:cY,
    Float:cZ
};
new Casas[MAX_CASAS][E_CASA_DATA] = {
    {"Ninguem", false, false, 15000, 2495.0, -1691.2, 13.5},
    {"Ninguem", false, false, 25000, 2468.0, -1698.0, 13.5},
    {"Ninguem", false, false, 40000, 2447.0, -1702.0, 13.5},
    {"Ninguem", false, false, 60000, 2523.0, -1679.0, 15.4},
    {"Ninguem", false, false, 85000, 2486.4, -1645.1, 14.0},
    {"Ninguem", false, false, 120000, 2352.0, -1655.0, 13.4}
};

// --- COORDENADAS PRINCIPAIS ---
#define POS_SPAWN_X         1481.0
#define POS_SPAWN_Y         -1771.0
#define POS_SPAWN_Z         18.8

#define POS_BANCO_X         1462.3
#define POS_BANCO_Y         -1012.5
#define POS_BANCO_Z         26.8

#define POS_CONCE_X         2131.5
#define POS_CONCE_Y         -1150.0
#define POS_CONCE_Z         24.1

#define POS_ROUPAS_X        2244.3
#define POS_ROUPAS_Y        -1665.5
#define POS_ROUPAS_Z        15.5

#define POS_LOJA247_X       1315.4
#define POS_LOJA247_Y       -898.8
#define POS_LOJA247_Z       39.5

#define POS_POSTO_X         1944.0
#define POS_POSTO_Y         -1772.5
#define POS_POSTO_Z         13.4

#define POS_DROGA_X         2166.0
#define POS_DROGA_Y         -1675.0
#define POS_DROGA_Z         15.0

// --- ROTAS DE TRABALHO ---
new Float:RotaEntregador[5][3] = {
    {1510.0, -1750.0, 13.5},
    {1580.0, -1700.0, 13.5},
    {1650.0, -1800.0, 13.5},
    {1720.0, -1850.0, 13.5},
    {1800.0, -1750.0, 13.5}
};

new Float:RotaOnibus[5][3] = {
    {1425.0, -1730.0, 13.5},
    {1190.0, -1350.0, 13.5},
    {1450.0, -1030.0, 23.8},
    {1950.0, -1450.0, 13.5},
    {1520.0, -1720.0, 13.5}
};

// --- CATALOGOS ---
new const SkinLoja[6] = {7, 14, 21, 23, 29, 240};
new const ModeloVeiculo[6] = {462, 468, 560, 541, 400, 411};
new const NomeVeiculo[6][24] = {"Faggio", "Sanchez", "Elegy", "Bullet", "Landstalker", "Infernus"};
new const PrecoVeiculo[6] = {1500, 3000, 12000, 25000, 15000, 45000};
new const ModeloDono[5] = {411, 522, 560, 451, 487};

// --- FORWARDS ---
forward TimerGeralServidor();
forward TimerFomeSede();

// ============================================================================
// UTILITARIOS E SALVAMENTO (CONTAS E CASAS)
// ============================================================================

stock GetNome(playerid)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    return nome;
}

stock bool:VerificarDono(playerid)
{
    if (!strcmp(GetNome(playerid), NOME_DONO, true)) return true;
    return false;
}

stock RemoverQuebra(str[])
{
    for (new i = 0; str[i] != '\0'; i++)
    {
        if (str[i] == '\r' || str[i] == '\n') str[i] = '\0';
    }
}

stock CaminhoConta(playerid, dest[], len)
{
    format(dest, len, "Contas/%s.ini", GetNome(playerid));
}

stock bool:ContaExiste(playerid)
{
    new arquivo[64];
    CaminhoConta(playerid, arquivo, sizeof(arquivo));
    return fexist(arquivo);
}

stock SalvarConta(playerid)
{
    if (!PlayerInfo[playerid][pLogado]) return 0;

    new arquivo[64], linha[128];
    CaminhoConta(playerid, arquivo, sizeof(arquivo));

    new File:f = fopen(arquivo, io_write);
    if (!f) return 0;

    PlayerInfo[playerid][pDinheiro] = GetPlayerMoney(playerid);

    format(linha, sizeof(linha), "Senha=%s\r\n", PlayerInfo[playerid][pSenha]); fwrite(f, linha);
    format(linha, sizeof(linha), "Dinheiro=%d\r\n", PlayerInfo[playerid][pDinheiro]); fwrite(f, linha);
    format(linha, sizeof(linha), "Banco=%d\r\n", PlayerInfo[playerid][pBanco]); fwrite(f, linha);
    format(linha, sizeof(linha), "Nivel=%d\r\n", PlayerInfo[playerid][pNivel]); fwrite(f, linha);
    format(linha, sizeof(linha), "XP=%d\r\n", PlayerInfo[playerid][pXP]); fwrite(f, linha);
    format(linha, sizeof(linha), "Skin=%d\r\n", PlayerInfo[playerid][pSkin]); fwrite(f, linha);
    format(linha, sizeof(linha), "Fome=%d\r\n", PlayerInfo[playerid][pFome]); fwrite(f, linha);
    format(linha, sizeof(linha), "Sede=%d\r\n", PlayerInfo[playerid][pSede]); fwrite(f, linha);
    format(linha, sizeof(linha), "CNH=%d\r\n", PlayerInfo[playerid][pCNH]); fwrite(f, linha);
    format(linha, sizeof(linha), "Emprego=%d\r\n", PlayerInfo[playerid][pEmprego]); fwrite(f, linha);
    format(linha, sizeof(linha), "Faccao=%d\r\n", PlayerInfo[playerid][pFaccao]); fwrite(f, linha);
    format(linha, sizeof(linha), "Drogas=%d\r\n", PlayerInfo[playerid][pDrogas]); fwrite(f, linha);
    format(linha, sizeof(linha), "KitMedico=%d\r\n", PlayerInfo[playerid][pKitMedico]); fwrite(f, linha);
    format(linha, sizeof(linha), "Comida=%d\r\n", PlayerInfo[playerid][pComida]); fwrite(f, linha);
    format(linha, sizeof(linha), "Agua=%d\r\n", PlayerInfo[playerid][pAgua]); fwrite(f, linha);
    format(linha, sizeof(linha), "Procurado=%d\r\n", PlayerInfo[playerid][pProcurado]); fwrite(f, linha);
    format(linha, sizeof(linha), "VehModelo=%d\r\n", PlayerInfo[playerid][pVehModelo]); fwrite(f, linha);

    fclose(f);
    return 1;
}

stock CarregarConta(playerid)
{
    new arquivo[64], linha[128];
    CaminhoConta(playerid, arquivo, sizeof(arquivo));

    new File:f = fopen(arquivo, io_read);
    if (!f) return 0;

    while (fread(f, linha))
    {
        RemoverQuebra(linha);
        new pos = strfind(linha, "=");
        if (pos == -1) continue;

        new chave[32], valor[64];
        strmid(chave, linha, 0, pos);
        strmid(valor, linha, pos + 1, strlen(linha));

        if (!strcmp(chave, "Senha")) format(PlayerInfo[playerid][pSenha], 32, "%s", valor);
        else if (!strcmp(chave, "Dinheiro")) PlayerInfo[playerid][pDinheiro] = strval(valor);
        else if (!strcmp(chave, "Banco")) PlayerInfo[playerid][pBanco] = strval(valor);
        else if (!strcmp(chave, "Nivel")) PlayerInfo[playerid][pNivel] = strval(valor);
        else if (!strcmp(chave, "XP")) PlayerInfo[playerid][pXP] = strval(valor);
        else if (!strcmp(chave, "Skin")) PlayerInfo[playerid][pSkin] = strval(valor);
        else if (!strcmp(chave, "Fome")) PlayerInfo[playerid][pFome] = strval(valor);
        else if (!strcmp(chave, "Sede")) PlayerInfo[playerid][pSede] = strval(valor);
        else if (!strcmp(chave, "CNH")) PlayerInfo[playerid][pCNH] = strval(valor);
        else if (!strcmp(chave, "Emprego")) PlayerInfo[playerid][pEmprego] = strval(valor);
        else if (!strcmp(chave, "Faccao")) PlayerInfo[playerid][pFaccao] = strval(valor);
        else if (!strcmp(chave, "Drogas")) PlayerInfo[playerid][pDrogas] = strval(valor);
        else if (!strcmp(chave, "KitMedico")) PlayerInfo[playerid][pKitMedico] = strval(valor);
        else if (!strcmp(chave, "Comida")) PlayerInfo[playerid][pComida] = strval(valor);
        else if (!strcmp(chave, "Agua")) PlayerInfo[playerid][pAgua] = strval(valor);
        else if (!strcmp(chave, "Procurado")) PlayerInfo[playerid][pProcurado] = strval(valor);
        else if (!strcmp(chave, "VehModelo")) PlayerInfo[playerid][pVehModelo] = strval(valor);
    }

    fclose(f);
    return 1;
}

stock SalvarCasas()
{
    new File:f = fopen("Dados/Casas.ini", io_write);
    if (!f) return 0;

    new linha[160];
    for (new i = 0; i < MAX_CASAS; i++)
    {
        format(linha, sizeof(linha), "%d|%s|%d|%d\r\n", i, Casas[i][cDono], Casas[i][cComprada] ? 1 : 0, Casas[i][cTrancada] ? 1 : 0);
        fwrite(f, linha);
    }
    fclose(f);
    return 1;
}

stock CarregarCasas()
{
    if (!fexist("Dados/Casas.ini")) return 0;
    new File:f = fopen("Dados/Casas.ini", io_read);
    if (!f) return 0;

    new linha[160];
    while (fread(f, linha))
    {
        RemoverQuebra(linha);
        new idx, dono[MAX_PLAYER_NAME], comp, tranc;
        new p1 = strfind(linha, "|");
        if (p1 == -1) continue;
        new p2 = strfind(linha, "|", false, p1 + 1);
        if (p2 == -1) continue;
        new p3 = strfind(linha, "|", false, p2 + 1);
        if (p3 == -1) continue;

        new tmp[32];
        strmid(tmp, linha, 0, p1); idx = strval(tmp);
        if (idx < 0 || idx >= MAX_CASAS) continue;

        strmid(dono, linha, p1 + 1, p2);
        strmid(tmp, linha, p2 + 1, p3); comp = strval(tmp);
        strmid(tmp, linha, p3 + 1, strlen(linha)); tranc = strval(tmp);

        format(Casas[idx][cDono], MAX_PLAYER_NAME, "%s", dono);
        Casas[idx][cComprada] = (comp == 1);
        Casas[idx][cTrancada] = (tranc == 1);
    }
    fclose(f);
    return 1;
}

stock EnviarMensagemLocal(playerid, Float:raio, cor, const texto[])
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i) && PlayerInfo[i][pLogado])
        {
            if (IsPlayerInRangeOfPoint(i, raio, x, y, z) && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))
            {
                SendClientMessage(i, cor, texto);
            }
        }
    }
    return 1;
}

stock EnviarMensagemPolicia(cor, const texto[])
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i) && PlayerInfo[i][pLogado] && PlayerInfo[i][pEmprego] == 3)
        {
            SendClientMessage(i, cor, texto);
        }
    }
}

stock ObterNomeEmprego(emprego)
{
    new nome[28];
    switch (emprego)
    {
        case 1: nome = "Entregador iFood";
        case 2: nome = "Motorista de Onibus";
        case 3: nome = "Policial Militar";
        case 4: nome = "Mecanico";
        default: nome = "Desempregado";
    }
    return nome;
}

stock ObterNomeFaccao(fac)
{
    new nome[24];
    if (fac == 1) nome = "Tropa ZK (Crime)";
    else nome = "Cidadao Civil";
    return nome;
}

stock CriarVeiculoComCombustivel(modelo, Float:x, Float:y, Float:z, Float:a, cor1, cor2)
{
    new vid = CreateVehicle(modelo, x, y, z, a, cor1, cor2, -1);
    if (vid > 0 && vid < MAX_VEICULOS_SERVIDOR)
    {
        CombustivelVeh[vid] = 100;
        MotorLigadoVeh[vid] = true;
    }
    return vid;
}

stock GetVelocidadeKMH(playerid)
{
    if (!IsPlayerInAnyVehicle(playerid)) return 0;
    new Float:vx, Float:vy, Float:vz;
    GetVehicleVelocity(GetPlayerVehicleID(playerid), vx, vy, vz);
    new Float:vel = floatsqroot((vx * vx) + (vy * vy) + (vz * vz)) * 180.0;
    return floatround(vel);
}

// ============================================================================
// HUD & BOTOES MOBILE
// ============================================================================

stock CriarHUD(playerid)
{
    if (HUDCriado[playerid]) return 1;

    HUDInfo[playerid] = CreatePlayerTextDraw(playerid, 14.0, 382.0, "ZK RP");
    PlayerTextDrawLetterSize(playerid, HUDInfo[playerid], 0.21, 1.05);
    PlayerTextDrawColor(playerid, HUDInfo[playerid], COR_BRANCO);
    PlayerTextDrawSetOutline(playerid, HUDInfo[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, HUDInfo[playerid], COR_PRETO);
    PlayerTextDrawFont(playerid, HUDInfo[playerid], 1);
    PlayerTextDrawSetProportional(playerid, HUDInfo[playerid], 1);
    PlayerTextDrawShow(playerid, HUDInfo[playerid]);

    HUDStatus[playerid] = CreatePlayerTextDraw(playerid, 495.0, 105.0, "Status");
    PlayerTextDrawLetterSize(playerid, HUDStatus[playerid], 0.21, 1.0);
    PlayerTextDrawColor(playerid, HUDStatus[playerid], COR_BRANCO);
    PlayerTextDrawSetOutline(playerid, HUDStatus[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, HUDStatus[playerid], COR_PRETO);
    PlayerTextDrawFont(playerid, HUDStatus[playerid], 1);
    PlayerTextDrawSetProportional(playerid, HUDStatus[playerid], 1);
    PlayerTextDrawShow(playerid, HUDStatus[playerid]);

    HUDVelocimetro[playerid] = CreatePlayerTextDraw(playerid, 495.0, 370.0, "0 KM/H");
    PlayerTextDrawLetterSize(playerid, HUDVelocimetro[playerid], 0.24, 1.15);
    PlayerTextDrawColor(playerid, HUDVelocimetro[playerid], COR_BRANCO);
    PlayerTextDrawSetOutline(playerid, HUDVelocimetro[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, HUDVelocimetro[playerid], COR_PRETO);
    PlayerTextDrawFont(playerid, HUDVelocimetro[playerid], 2);
    PlayerTextDrawSetProportional(playerid, HUDVelocimetro[playerid], 1);

    HUDCriado[playerid] = true;
    VelocimetroVisivel[playerid] = false;
    AtualizarTextoHUD(playerid);
    return 1;
}

stock AtualizarTextoHUD(playerid)
{
    if (!IsPlayerConnected(playerid) || !HUDCriado[playerid] || !PlayerInfo[playerid][pLogado]) return 1;

    new texto[180], status[150];
    new tag[16] = "";
    if (PlayerInfo[playerid][pEhDono]) tag = "[DONO] ";

    format(texto, sizeof(texto),
        "~p~ZK RP~w~ | %s%s (Nv.%d)~n~~g~Mao: $%d ~w~| ~b~Banco: $%d",
        tag,
        GetNome(playerid),
        PlayerInfo[playerid][pNivel],
        GetPlayerMoney(playerid),
        PlayerInfo[playerid][pBanco]
    );
    PlayerTextDrawSetString(playerid, HUDInfo[playerid], texto);

    format(status, sizeof(status),
        "~y~Fome:~w~ %d%%~n~~b~Sede:~w~ %d%%~n~~p~Cargo:~w~ %s",
        PlayerInfo[playerid][pFome],
        PlayerInfo[playerid][pSede],
        ObterNomeEmprego(PlayerInfo[playerid][pEmprego])
    );
    PlayerTextDrawSetString(playerid, HUDStatus[playerid], status);

    if (IsPlayerInAnyVehicle(playerid))
    {
        if (!VelocimetroVisivel[playerid])
        {
            PlayerTextDrawShow(playerid, HUDVelocimetro[playerid]);
            VelocimetroVisivel[playerid] = true;
        }
        new vid = GetPlayerVehicleID(playerid);
        new velStr[96];
        format(velStr, sizeof(velStr), "~w~VEL: ~p~%d KM/H~n~~y~COMBUSTIVEL: ~w~%d%%", GetVelocidadeKMH(playerid), CombustivelVeh[vid]);
        PlayerTextDrawSetString(playerid, HUDVelocimetro[playerid], velStr);
    }
    else if (VelocimetroVisivel[playerid])
    {
        PlayerTextDrawHide(playerid, HUDVelocimetro[playerid]);
        VelocimetroVisivel[playerid] = false;
    }
    return 1;
}

stock CriarBotaoMobile(Float:x, Float:y, const texto[], corBox)
{
    new Text:td = TextDrawCreate(x, y, texto);
    TextDrawLetterSize(td, 0.21, 1.1);
    TextDrawTextSize(td, x + 48.0, 17.0);
    TextDrawAlignment(td, 1);
    TextDrawColor(td, COR_BRANCO);
    TextDrawUseBox(td, 1);
    TextDrawBoxColor(td, corBox);
    TextDrawSetOutline(td, 1);
    TextDrawSetSelectable(td, 1);
    TextDrawFont(td, 1);
    return td;
}

// ============================================================================
// CALLBACKS PRINCIPAIS
// ============================================================================

public OnGameModeInit()
{
    SetGameModeText("ZK RP v3.0 | Mobile RP");
    ShowNameTags(true);
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_STREAMED);
    UsePlayerPedAnims();
    DisableInteriorEnterExits();
    SetWorldTime(12);
    SetWeather(10);

    CarregarCasas();

    LogoZK = TextDrawCreate(548.0, 12.0, "ZK");
    TextDrawLetterSize(LogoZK, 0.38, 1.6);
    TextDrawColor(LogoZK, COR_BRANCO);
    TextDrawSetOutline(LogoZK, 1);
    TextDrawFont(LogoZK, 2);

    LogoRP = TextDrawCreate(580.0, 12.0, "RP");
    TextDrawLetterSize(LogoRP, 0.30, 1.3);
    TextDrawColor(LogoRP, COR_ROXO);
    TextDrawSetOutline(LogoRP, 1);
    TextDrawFont(LogoRP, 2);

    // 5 Botoes Touch na base esquerda
    BtnMenu      = CriarBotaoMobile(12.0, 355.0, " MENU", COR_ROXO);
    BtnInteragir = CriarBotaoMobile(64.0, 355.0, "  ACAO", COR_VERDE);
    BtnVeiculo   = CriarBotaoMobile(116.0, 355.0, "CARRO", COR_AZUL);
    BtnGPS       = CriarBotaoMobile(168.0, 355.0, "  GPS", COR_LARANJA);
    BtnCelular   = CriarBotaoMobile(220.0, 355.0, "FONE", COR_CIANO);

    // Locais do Mapa
    CreatePickup(1239, 1, POS_SPAWN_X, POS_SPAWN_Y, POS_SPAWN_Z, 0);
    Create3DTextLabel("{9B59B6}[PREFEITURA & AUTO-ESCOLA]\n{FFFFFF}Toque em ACAO", COR_BRANCO, POS_SPAWN_X, POS_SPAWN_Y, POS_SPAWN_Z + 0.5, 15.0, 0);

    CreatePickup(1274, 1, POS_BANCO_X, POS_BANCO_Y, POS_BANCO_Z, 0);
    Create3DTextLabel("{2ECC71}[BANCO CENTRAL]\n{FFFFFF}Toque em ACAO", COR_BRANCO, POS_BANCO_X, POS_BANCO_Y, POS_BANCO_Z + 0.5, 15.0, 0);

    CreatePickup(1277, 1, POS_CONCE_X, POS_CONCE_Y, POS_CONCE_Z, 0);
    Create3DTextLabel("{3498DB}[CONCESSIONARIA]\n{FFFFFF}Toque em ACAO", COR_BRANCO, POS_CONCE_X, POS_CONCE_Y, POS_CONCE_Z + 0.5, 15.0, 0);

    CreatePickup(1275, 1, POS_ROUPAS_X, POS_ROUPAS_Y, POS_ROUPAS_Z, 0);
    Create3DTextLabel("{E67E22}[LOJA DE ROUPAS]\n{FFFFFF}Toque em ACAO", COR_BRANCO, POS_ROUPAS_X, POS_ROUPAS_Y, POS_ROUPAS_Z + 0.5, 15.0, 0);

    CreatePickup(1240, 1, POS_LOJA247_X, POS_LOJA247_Y, POS_LOJA247_Z, 0);
    Create3DTextLabel("{F1C40F}[MERCADO 24/7]\n{FFFFFF}Toque em ACAO", COR_BRANCO, POS_LOJA247_X, POS_LOJA247_Y, POS_LOJA247_Z + 0.5, 15.0, 0);

    CreatePickup(1650, 1, POS_POSTO_X, POS_POSTO_Y, POS_POSTO_Z, 0);
    Create3DTextLabel("{E74C3C}[POSTO & OFICINA]\n{FFFFFF}Toque em ACAO", COR_BRANCO, POS_POSTO_X, POS_POSTO_Y, POS_POSTO_Z + 0.5, 15.0, 0);

    CreatePickup(1279, 1, POS_DROGA_X, POS_DROGA_Y, POS_DROGA_Z, 0);
    Create3DTextLabel("{9B59B6}[PONTO DA TROPA ZK]\n{FFFFFF}Toque em ACAO", COR_BRANCO, POS_DROGA_X, POS_DROGA_Y, POS_DROGA_Z + 0.5, 15.0, 0);

    for (new i = 0; i < MAX_CASAS; i++)
    {
        CreatePickup(1273, 1, Casas[i][cX], Casas[i][cY], Casas[i][cZ], 0);
        new label[144];
        if (Casas[i][cComprada])
            format(label, sizeof(label), "{9B59B6}[CASA #%d]\n{FFFFFF}Dono: %s\nToque em ACAO", i + 1, Casas[i][cDono]);
        else
            format(label, sizeof(label), "{9B59B6}[CASA #%d A VENDA]\n{2ECC71}Valor: $%d\n{FFFFFF}Toque em ACAO", i + 1, Casas[i][cPreco]);
        Create3DTextLabel(label, COR_BRANCO, Casas[i][cX], Casas[i][cY], Casas[i][cZ] + 0.5, 12.0, 0);
    }

    SetTimer("TimerGeralServidor", 1000, true);
    SetTimer("TimerFomeSede", TEMPO_FOME_SEGUNDOS * 1000, true);
    return 1;
}

public OnGameModeExit()
{
    SalvarCasas();
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i) && PlayerInfo[i][pLogado]) SalvarConta(i);
    }
    TextDrawDestroy(LogoZK);
    TextDrawDestroy(LogoRP);
    TextDrawDestroy(BtnMenu);
    TextDrawDestroy(BtnInteragir);
    TextDrawDestroy(BtnVeiculo);
    TextDrawDestroy(BtnGPS);
    TextDrawDestroy(BtnCelular);
    return 1;
}

public OnPlayerConnect(playerid)
{
    new vazio[E_PLAYER_DATA];
    PlayerInfo[playerid] = vazio;

    PlayerInfo[playerid][pEhDono] = VerificarDono(playerid);
    PlayerInfo[playerid][pNivel] = 1;
    PlayerInfo[playerid][pDinheiro] = 3000;
    PlayerInfo[playerid][pBanco] = 1500;
    PlayerInfo[playerid][pSkin] = 23;
    PlayerInfo[playerid][pFome] = 100;
    PlayerInfo[playerid][pSede] = 100;
    PlayerInfo[playerid][pComida] = 2;
    PlayerInfo[playerid][pAgua] = 2;
    PlayerInfo[playerid][pCasaAtual] = -1;
    HUDCriado[playerid] = false;

    TogglePlayerClock(playerid, 0);
    SetPlayerColor(playerid, COR_BRANCO);

    for (new i = 0; i < 12; i++) SendClientMessage(playerid, -1, " ");

    SendClientMessage(playerid, COR_ROXO, "==============================================");
    SendClientMessage(playerid, COR_BRANCO, "   Bem-vindo ao {9B59B6}ZK RP Mobile v3.0{FFFFFF}!");
    SendClientMessage(playerid, COR_CINZA, "   Roleplay completo com economia, faccoes e frotas.");
    SendClientMessage(playerid, COR_ROXO, "==============================================");

    if (ContaExiste(playerid))
    {
        CarregarConta(playerid);
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
            "{9B59B6}ZK RP {FFFFFF}- Login",
            "Conta encontrada! Digite sua senha para entrar:",
            "Entrar", "Sair"
        );
    }
    else
    {
        ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD,
            "{9B59B6}ZK RP {FFFFFF}- Registro",
            "Primeiro acesso! Crie uma senha (4 a 24 caracteres):",
            "Registrar", "Sair"
        );
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if (PlayerInfo[playerid][pLogado]) SalvarConta(playerid);

    if (HUDCriado[playerid])
    {
        PlayerTextDrawDestroy(playerid, HUDInfo[playerid]);
        PlayerTextDrawDestroy(playerid, HUDStatus[playerid]);
        PlayerTextDrawDestroy(playerid, HUDVelocimetro[playerid]);
        HUDCriado[playerid] = false;
    }

    if (PlayerInfo[playerid][pTrabalhando] && PlayerInfo[playerid][pVehTrabalho] != 0)
        DestroyVehicle(PlayerInfo[playerid][pVehTrabalho]);

    if (PlayerInfo[playerid][pVehSpawnado])
        DestroyVehicle(PlayerInfo[playerid][pVehID]);

    return 1;
}

public OnPlayerSpawn(playerid)
{
    if (!PlayerInfo[playerid][pLogado])
    {
        Kick(playerid);
        return 1;
    }

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid, POS_SPAWN_X, POS_SPAWN_Y, POS_SPAWN_Z);
    SetPlayerFacingAngle(playerid, 90.0);
    SetCameraBehindPlayer(playerid);

    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, PlayerInfo[playerid][pDinheiro]);
    SetPlayerScore(playerid, PlayerInfo[playerid][pNivel]);
    SetPlayerWantedLevel(playerid, PlayerInfo[playerid][pProcurado]);

    if (PlayerInfo[playerid][pEhDono])
    {
        SetPlayerSkin(playerid, 217);
        SendClientMessage(playerid, COR_DOURADO, "[DONO] Acesso liberado. Use /dono para abrir o painel.");
    }
    else
    {
        SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
    }

    TextDrawShowForPlayer(playerid, LogoZK);
    TextDrawShowForPlayer(playerid, LogoRP);
    TextDrawShowForPlayer(playerid, BtnMenu);
    TextDrawShowForPlayer(playerid, BtnInteragir);
    TextDrawShowForPlayer(playerid, BtnVeiculo);
    TextDrawShowForPlayer(playerid, BtnGPS);
    TextDrawShowForPlayer(playerid, BtnCelular);

    SelectTextDraw(playerid, COR_ROXO);
    CriarHUD(playerid);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if (PlayerInfo[playerid][pTrabalhando]) PararTrabalho(playerid);

    if (killerid != INVALID_PLAYER_ID && IsPlayerConnected(killerid))
    {
        // Quem mata civil sem ser PM ganha nivel de procurado
        if (PlayerInfo[killerid][pEmprego] != 3)
        {
            if (PlayerInfo[killerid][pProcurado] < 6) PlayerInfo[killerid][pProcurado]++;
            SetPlayerWantedLevel(killerid, PlayerInfo[killerid][pProcurado]);
            SendClientMessage(killerid, COR_VERMELHO, "[PROCURADO] Voce cometeu um homicidio e sua estrela aumentou!");
            EnviarMensagemPolicia(COR_AZUL, "[COPOM] Denuncia de homicidio na cidade! Fiquem atentos.");
        }
    }

    if (GetPlayerMoney(playerid) >= 200)
    {
        GivePlayerMoney(playerid, -200);
        SendClientMessage(playerid, COR_VERMELHO, "[HOSPITAL] Taxa medica de $200 descontada.");
    }

    PlayerInfo[playerid][pFome] = 75;
    PlayerInfo[playerid][pSede] = 75;
    return 1;
}

public OnPlayerText(playerid, text[])
{
    if (!PlayerInfo[playerid][pLogado]) return 0;

    new msg[144];
    if (PlayerInfo[playerid][pEhDono])
        format(msg, sizeof(msg), "{F1C40F}[DONO] {FFFFFF}%s diz: %s", GetNome(playerid), text);
    else
        format(msg, sizeof(msg), "%s diz: %s", GetNome(playerid), text);

    EnviarMensagemLocal(playerid, 20.0, COR_BRANCO, msg);
    return 0;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if (_:clickedid == INVALID_TEXT_DRAW)
    {
        if (PlayerInfo[playerid][pLogado]) SelectTextDraw(playerid, COR_ROXO);
        return 1;
    }

    if (clickedid == BtnMenu) { MostrarMenuPrincipal(playerid); return 1; }
    if (clickedid == BtnInteragir) { ProcessarInteracaoContextual(playerid); return 1; }
    if (clickedid == BtnVeiculo) { MostrarMenuVeiculo(playerid); return 1; }
    if (clickedid == BtnGPS) { MostrarMenuGPS(playerid); return 1; }
    if (clickedid == BtnCelular) { MostrarMenuCelular(playerid); return 1; }
    return 0;
}

// ============================================================================
// INTERACAO POR PROXIMIDADE
// ============================================================================

stock ProcessarInteracaoContextual(playerid)
{
    if (PlayerInfo[playerid][pDentroCasa])
    {
        PlayerInfo[playerid][pDentroCasa] = false;
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        new c = PlayerInfo[playerid][pCasaAtual];
        if (c >= 0 && c < MAX_CASAS) SetPlayerPos(playerid, Casas[c][cX] + 2.0, Casas[c][cY], Casas[c][cZ]);
        SendClientMessage(playerid, COR_CINZA, "Voce saiu da casa.");
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 3.5, POS_SPAWN_X, POS_SPAWN_Y, POS_SPAWN_Z))
    {
        ShowPlayerDialog(playerid, DIALOG_PREFEITURA, DIALOG_STYLE_LIST,
            "{9B59B6}Prefeitura & Auto-Escola",
            "Tirar CNH - $1.200\nAgencia de Empregos\nEntrar / Sair da Faccao Tropa ZK\nLimpar Ficha Criminal - $2.000",
            "Selecionar", "Fechar"
        );
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 3.5, POS_BANCO_X, POS_BANCO_Y, POS_BANCO_Z))
    {
        MostrarMenuBanco(playerid);
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 4.0, POS_CONCE_X, POS_CONCE_Y, POS_CONCE_Z))
    {
        ShowPlayerDialog(playerid, DIALOG_CONCESSIONARIA, DIALOG_STYLE_LIST,
            "{3498DB}Concessionaria ZK Motors",
            "Faggio - $1.500\nSanchez - $3.000\nElegy - $12.000\nBullet - $25.000\nLandstalker - $15.000\nInfernus - $45.000",
            "Comprar", "Fechar"
        );
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 3.5, POS_ROUPAS_X, POS_ROUPAS_Y, POS_ROUPAS_Z))
    {
        ShowPlayerDialog(playerid, DIALOG_ROUPAS, DIALOG_STYLE_LIST,
            "{E67E22}Loja de Roupas",
            "Estilo 1 - $500\nEstilo 2 - $500\nEstilo 3 - $500\nEstilo 4 - $500\nEstilo 5 - $500\nEstilo 6 - $500",
            "Comprar", "Fechar"
        );
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 3.5, POS_LOJA247_X, POS_LOJA247_Y, POS_LOJA247_Z))
    {
        ShowPlayerDialog(playerid, DIALOG_LOJA_247, DIALOG_STYLE_LIST,
            "{F1C40F}Mercado 24/7",
            "Combo Lanche (2x Comida) - $80\nCombo Agua (2x Agua) - $50\nKit Medico (1x Kit) - $220",
            "Comprar", "Fechar"
        );
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 4.5, POS_POSTO_X, POS_POSTO_Y, POS_POSTO_Z))
    {
        ShowPlayerDialog(playerid, DIALOG_POSTO, DIALOG_STYLE_LIST,
            "{E74C3C}Posto & Oficina ZK",
            "Abastecer Tanque Completo ($5/Litro)\nReparar Lataria e Motor do Veiculo ($350)",
            "Executar", "Fechar"
        );
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 3.5, POS_DROGA_X, POS_DROGA_Y, POS_DROGA_Z))
    {
        ShowPlayerDialog(playerid, DIALOG_FACCAO, DIALOG_STYLE_LIST,
            "{9B59B6}Ponto da Tropa ZK",
            "Produzir Carga de Drogas (Gratis - Risco PM)\nVender Carga de Drogas ($600/unidade)",
            "Executar", "Fechar"
        );
        return 1;
    }

    for (new i = 0; i < MAX_CASAS; i++)
    {
        if (IsPlayerInRangeOfPoint(playerid, 3.0, Casas[i][cX], Casas[i][cY], Casas[i][cZ]))
        {
            PlayerInfo[playerid][pCasaAtual] = i;
            MostrarMenuCasa(playerid, i);
            return 1;
        }
    }

    SendClientMessage(playerid, COR_CINZA, "Nenhum local interativo proximo. Use o GPS!");
    return 1;
}

// ============================================================================
// MENUS
// ============================================================================

stock MostrarMenuPrincipal(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_MENU_PRINCIPAL, DIALOG_STYLE_LIST,
        "{9B59B6}ZK RP v3.0 {FFFFFF}- Menu",
        "Meu RG & Status\nInventario & Itens\nGPS / Locais\nGaragem & Veiculo\nCentral de Empregos\nMenu Policial (PM)\nSalvar Conta",
        "Selecionar", "Fechar"
    );
}

stock MostrarInventario(playerid)
{
    new inv[220];
    format(inv, sizeof(inv),
        "Comer Lanche (Tem: %d)\nBeber Agua (Tem: %d)\nUsar Kit Medico (+50 Vida | Tem: %d)\nCarga de Drogas na Mochila: %d",
        PlayerInfo[playerid][pComida],
        PlayerInfo[playerid][pAgua],
        PlayerInfo[playerid][pKitMedico],
        PlayerInfo[playerid][pDrogas]
    );
    ShowPlayerDialog(playerid, DIALOG_INVENTARIO, DIALOG_STYLE_LIST, "{2ECC71}Inventario do Personagem", inv, "Usar", "Voltar");
}

stock MostrarMenuGPS(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST,
        "{E67E22}GPS Mobile",
        "Prefeitura & Auto-Escola\nBanco Central\nConcessionaria\nLoja de Roupas\nMercado 24/7\nPosto de Gasolina & Oficina\nPonto da Tropa ZK (Crime)\nDesativar GPS",
        "Marcar", "Fechar"
    );
}

stock MostrarMenuCelular(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_CELULAR, DIALOG_STYLE_LIST,
        "{1ABC9C}iZK Phone {FFFFFF}- Celular Mobile",
        "Enviar SMS para Jogador (ID)\nPostar Anuncio na Cidade ($150)\nChamar Policia / Emergencia (190)",
        "Abrir", "Fechar"
    );
}

stock MostrarMenuBanco(playerid)
{
    new titulo[64];
    format(titulo, sizeof(titulo), "{2ECC71}Banco Central {FFFFFF}| Saldo: $%d", PlayerInfo[playerid][pBanco]);
    ShowPlayerDialog(playerid, DIALOG_BANCO, DIALOG_STYLE_LIST,
        titulo,
        "Depositar\nSacar\nTransferir para Jogador (ID)",
        "Selecionar", "Fechar"
    );
}

stock MostrarMenuVeiculo(playerid)
{
    if (PlayerInfo[playerid][pVehModelo] == 0)
    {
        SendClientMessage(playerid, COR_VERMELHO, "Voce ainda nao tem veiculo proprio. Va a Concessionaria!");
        return 1;
    }

    new info[180];
    format(info, sizeof(info),
        "%s Veiculo na Rua\nTrancar / Destrancar\nLigar / Desligar Motor\nLocalizar no GPS",
        PlayerInfo[playerid][pVehSpawnado] ? "Guardar" : "Retirar"
    );
    ShowPlayerDialog(playerid, DIALOG_VEICULO_MENU, DIALOG_STYLE_LIST, "{3498DB}Meu Veiculo", info, "Selecionar", "Fechar");
    return 1;
}

stock MostrarMenuCasa(playerid, casaid)
{
    new texto[180];
    if (Casas[casaid][cComprada] && !strcmp(Casas[casaid][cDono], GetNome(playerid), true))
    {
        format(texto, sizeof(texto),
            "Entrar na Casa\n%s Casa\nVender Casa ($%d)",
            Casas[casaid][cTrancada] ? "Destrancar" : "Trancar",
            Casas[casaid][cPreco] / 2
        );
    }
    else if (!Casas[casaid][cComprada])
    {
        format(texto, sizeof(texto), "Comprar Casa por $%d", Casas[casaid][cPreco]);
    }
    else
    {
        format(texto, sizeof(texto), "Dono: %s\nEntrar (se destrancada)", Casas[casaid][cDono]);
    }

    ShowPlayerDialog(playerid, DIALOG_CASA, DIALOG_STYLE_LIST, "{9B59B6}Imovel", texto, "Selecionar", "Fechar");
}

// ============================================================================
// TRABALHO
// ============================================================================

stock IniciarTrabalho(playerid)
{
    if (PlayerInfo[playerid][pTrabalhando])
        return SendClientMessage(playerid, COR_VERMELHO, "Voce ja esta trabalhando!");

    new emp = PlayerInfo[playerid][pEmprego];
    if (emp == 0)
        return SendClientMessage(playerid, COR_VERMELHO, "Voce esta desempregado!");

    if (emp == 3)
    {
        PlayerInfo[playerid][pTrabalhando] = true;
        SetPlayerSkin(playerid, 280);
        SetPlayerArmour(playerid, 100.0);
        GivePlayerWeapon(playerid, 3, 1);
        GivePlayerWeapon(playerid, 24, 100);
        GivePlayerWeapon(playerid, 29, 200);
        SendClientMessage(playerid, COR_AZUL, "[PM] Voce entrou em servico!");
        return 1;
    }

    if (emp == 4)
    {
        PlayerInfo[playerid][pTrabalhando] = true;
        SetPlayerSkin(playerid, 50);
        SendClientMessage(playerid, COR_LARANJA, "[MECANICO] Em servico! Use /reparar proximo a um veiculo.");
        return 1;
    }

    if (PlayerInfo[playerid][pCNH] == 0 && !PlayerInfo[playerid][pEhDono])
        return SendClientMessage(playerid, COR_VERMELHO, "Tire sua CNH na Prefeitura antes de trabalhar dirigindo!");

    PlayerInfo[playerid][pTrabalhando] = true;
    PlayerInfo[playerid][pEtapaTrabalho] = 0;

    if (emp == 1)
    {
        SetPlayerSkin(playerid, 155);
        PlayerInfo[playerid][pVehTrabalho] = CriarVeiculoComCombustivel(448, 1477.5, -1771.0, 13.5, 90.0, 3, 1);
        PutPlayerInVehicle(playerid, PlayerInfo[playerid][pVehTrabalho], 0);
        SetPlayerCheckpoint(playerid, RotaEntregador[0][0], RotaEntregador[0][1], RotaEntregador[0][2], 4.0);
        SendClientMessage(playerid, COR_VERDE, "[iFood] Rota iniciada! Siga os checkpoints.");
    }
    else if (emp == 2)
    {
        SetPlayerSkin(playerid, 255);
        PlayerInfo[playerid][pVehTrabalho] = CriarVeiculoComCombustivel(431, 1465.0, -1735.0, 13.5, 90.0, 6, 1);
        PutPlayerInVehicle(playerid, PlayerInfo[playerid][pVehTrabalho], 0);
        SetPlayerCheckpoint(playerid, RotaOnibus[0][0], RotaOnibus[0][1], RotaOnibus[0][2], 5.0);
        SendClientMessage(playerid, COR_VERDE, "[ONIBUS] Linha iniciada! Siga os pontos de parada.");
    }
    return 1;
}

stock PararTrabalho(playerid)
{
    if (!PlayerInfo[playerid][pTrabalhando]) return 1;

    PlayerInfo[playerid][pTrabalhando] = false;
    DisablePlayerCheckpoint(playerid);

    if (PlayerInfo[playerid][pVehTrabalho] != 0)
    {
        DestroyVehicle(PlayerInfo[playerid][pVehTrabalho]);
        PlayerInfo[playerid][pVehTrabalho] = 0;
    }

    ResetPlayerWeapons(playerid);
    SetPlayerSkin(playerid, PlayerInfo[playerid][pEhDono] ? 217 : PlayerInfo[playerid][pSkin]);
    SendClientMessage(playerid, COR_CINZA, "Expediente encerrado.");
    return 1;
}

// ============================================================================
// DIALOG RESPONSE
// ============================================================================

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (!response)
    {
        if (dialogid == DIALOG_LOGIN || dialogid == DIALOG_REGISTRO) Kick(playerid);
        else SelectTextDraw(playerid, COR_ROXO);
        return 1;
    }

    switch (dialogid)
    {
        case DIALOG_REGISTRO:
        {
            if (strlen(inputtext) < 4 || strlen(inputtext) > 24)
            {
                ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD,
                    "{9B59B6}ZK RP {FFFFFF}- Registro",
                    "{E74C3C}Use entre 4 e 24 caracteres:",
                    "Registrar", "Sair"
                );
                return 1;
            }
            format(PlayerInfo[playerid][pSenha], 32, "%s", inputtext);
            PlayerInfo[playerid][pLogado] = true;
            SalvarConta(playerid);
            SpawnPlayer(playerid);
            SendClientMessage(playerid, COR_VERDE, "Conta criada! Voce recebeu $3.000 em maos e $1.500 no banco.");
        }

        case DIALOG_LOGIN:
        {
            if (strcmp(inputtext, PlayerInfo[playerid][pSenha], false) == 0)
            {
                PlayerInfo[playerid][pLogado] = true;
                SpawnPlayer(playerid);
                SendClientMessage(playerid, COR_VERDE, "Login efetuado com sucesso!");
            }
            else
            {
                ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
                    "{9B59B6}ZK RP {FFFFFF}- Login",
                    "{E74C3C}Senha incorreta! Tente novamente:",
                    "Entrar", "Sair"
                );
            }
        }

        case DIALOG_MENU_PRINCIPAL:
        {
            switch (listitem)
            {
                case 0:
                {
                    new rg[280];
                    format(rg, sizeof(rg),
                        "{FFFFFF}Nome: {9B59B6}%s {FFFFFF}(ID: %d)\nNivel: {F1C40F}%d {FFFFFF}(XP: %d/5)\nMao: {2ECC71}$%d {FFFFFF}| Banco: {3498DB}$%d\nEmprego: %s\nFaccao: %s\nCNH: %s\nProcurado: %d estrela(s)",
                        GetNome(playerid), playerid,
                        PlayerInfo[playerid][pNivel], PlayerInfo[playerid][pXP],
                        GetPlayerMoney(playerid), PlayerInfo[playerid][pBanco],
                        ObterNomeEmprego(PlayerInfo[playerid][pEmprego]),
                        ObterNomeFaccao(PlayerInfo[playerid][pFaccao]),
                        PlayerInfo[playerid][pCNH] ? "{2ECC71}Sim" : "{E74C3C}Nao",
                        PlayerInfo[playerid][pProcurado]
                    );
                    ShowPlayerDialog(playerid, DIALOG_RG_STATS, DIALOG_STYLE_MSGBOX, "{9B59B6}RG & Estatisticas", rg, "Voltar", "Fechar");
                }
                case 1: MostrarInventario(playerid);
                case 2: MostrarMenuGPS(playerid);
                case 3: MostrarMenuVeiculo(playerid);
                case 4:
                {
                    ShowPlayerDialog(playerid, DIALOG_EMPREGOS, DIALOG_STYLE_LIST,
                        "{9B59B6}Empregos",
                        "Entregador iFood ($250/rota)\nMotorista de Onibus ($400/rota)\nPolicial Militar (Patrulha & Prisao)\nMecanico (Reparar Veiculos)\nIniciar Expediente\nEncerrar Expediente",
                        "Selecionar", "Voltar"
                    );
                }
                case 5:
                {
                    if (PlayerInfo[playerid][pEmprego] != 3)
                        return SendClientMessage(playerid, COR_VERMELHO, "Apenas Policiais Militares!");

                    ShowPlayerDialog(playerid, DIALOG_POLICIA, DIALOG_STYLE_LIST,
                        "{3498DB}Central Policial",
                        "Pegar Equipamento\nLocalizar Procurado Proximo\nPrender Procurado Proximo (+$1.000)",
                        "Executar", "Fechar"
                    );
                }
                case 6:
                {
                    SalvarConta(playerid);
                    SalvarCasas();
                    SendClientMessage(playerid, COR_VERDE, "Conta e casas salvas!");
                }
            }
        }

        case DIALOG_RG_STATS: MostrarMenuPrincipal(playerid);

        case DIALOG_INVENTARIO:
        {
            switch (listitem)
            {
                case 0:
                {
                    if (PlayerInfo[playerid][pComida] <= 0) return SendClientMessage(playerid, COR_VERMELHO, "Voce nao tem lanche.");
                    PlayerInfo[playerid][pComida]--;
                    PlayerInfo[playerid][pFome] = (PlayerInfo[playerid][pFome] + 45 > 100) ? 100 : PlayerInfo[playerid][pFome] + 45;
                    SendClientMessage(playerid, COR_VERDE, "Voce comeu um lanche! Fome recuperada.");
                }
                case 1:
                {
                    if (PlayerInfo[playerid][pAgua] <= 0) return SendClientMessage(playerid, COR_VERMELHO, "Voce nao tem agua.");
                    PlayerInfo[playerid][pAgua]--;
                    PlayerInfo[playerid][pSede] = (PlayerInfo[playerid][pSede] + 45 > 100) ? 100 : PlayerInfo[playerid][pSede] + 45;
                    SendClientMessage(playerid, COR_VERDE, "Voce bebeu agua! Sede recuperada.");
                }
                case 2:
                {
                    if (PlayerInfo[playerid][pKitMedico] <= 0) return SendClientMessage(playerid, COR_VERMELHO, "Voce nao tem Kit Medico.");
                    PlayerInfo[playerid][pKitMedico]--;
                    new Float:hp; GetPlayerHealth(playerid, hp);
                    SetPlayerHealth(playerid, (hp + 50.0 > 100.0) ? 100.0 : hp + 50.0);
                    SendClientMessage(playerid, COR_VERDE, "Kit Medico usado (+50 de vida)!");
                }
            }
            AtualizarTextoHUD(playerid);
        }

        case DIALOG_GPS:
        {
            switch (listitem)
            {
                case 0: SetPlayerCheckpoint(playerid, POS_SPAWN_X, POS_SPAWN_Y, POS_SPAWN_Z, 4.0);
                case 1: SetPlayerCheckpoint(playerid, POS_BANCO_X, POS_BANCO_Y, POS_BANCO_Z, 4.0);
                case 2: SetPlayerCheckpoint(playerid, POS_CONCE_X, POS_CONCE_Y, POS_CONCE_Z, 4.0);
                case 3: SetPlayerCheckpoint(playerid, POS_ROUPAS_X, POS_ROUPAS_Y, POS_ROUPAS_Z, 4.0);
                case 4: SetPlayerCheckpoint(playerid, POS_LOJA247_X, POS_LOJA247_Y, POS_LOJA247_Z, 4.0);
                case 5: SetPlayerCheckpoint(playerid, POS_POSTO_X, POS_POSTO_Y, POS_POSTO_Z, 4.0);
                case 6: SetPlayerCheckpoint(playerid, POS_DROGA_X, POS_DROGA_Y, POS_DROGA_Z, 4.0);
                case 7:
                {
                    DisablePlayerCheckpoint(playerid);
                    SendClientMessage(playerid, COR_CINZA, "GPS desligado.");
                    return 1;
                }
            }
            SendClientMessage(playerid, COR_LARANJA, "[GPS] Rota marcada no mapa!");
        }

        case DIALOG_CELULAR:
        {
            switch (listitem)
            {
                case 0: ShowPlayerDialog(playerid, DIALOG_CELULAR_SMS_ID, DIALOG_STYLE_INPUT, "{1ABC9C}Enviar SMS", "Digite o ID do jogador:", "Avancar", "Voltar");
                case 1: ShowPlayerDialog(playerid, DIALOG_CELULAR_ANUNCIO, DIALOG_STYLE_INPUT, "{1ABC9C}Anuncio Global ($150)", "Digite o texto do anuncio para a cidade:", "Publicar", "Voltar");
                case 2:
                {
                    new alerta[128];
                    format(alerta, sizeof(alerta), "[190 EMERGENCIA] %s (ID %d) solicitou apoio policial!", GetNome(playerid), playerid);
                    EnviarMensagemPolicia(COR_AZUL, alerta);
                    SendClientMessage(playerid, COR_AZUL, "[190] Chamado enviado para os policiais em patrulha.");
                }
            }
        }

        case DIALOG_CELULAR_SMS_ID:
        {
            new alvo = strval(inputtext);
            if (!IsPlayerConnected(alvo) || !PlayerInfo[alvo][pLogado])
                return SendClientMessage(playerid, COR_VERMELHO, "Jogador offline ou ID invalido.");
            PlayerInfo[playerid][pAlvoSMS] = alvo;
            ShowPlayerDialog(playerid, DIALOG_CELULAR_SMS_TXT, DIALOG_STYLE_INPUT, "{1ABC9C}Mensagem SMS", "Digite sua mensagem:", "Enviar", "Cancelar");
        }

        case DIALOG_CELULAR_SMS_TXT:
        {
            new alvo = PlayerInfo[playerid][pAlvoSMS];
            if (!IsPlayerConnected(alvo)) return SendClientMessage(playerid, COR_VERMELHO, "Jogador desconectou.");
            if (strlen(inputtext) < 1) return SendClientMessage(playerid, COR_VERMELHO, "Mensagem vazia.");

            new m1[144], m2[144];
            format(m1, sizeof(m1), "[SMS para %s]: %s", GetNome(alvo), inputtext);
            format(m2, sizeof(m2), "[SMS de %s (ID %d)]: %s", GetNome(playerid), playerid, inputtext);
            SendClientMessage(playerid, COR_DOURADO, m1);
            SendClientMessage(alvo, COR_DOURADO, m2);
        }

        case DIALOG_CELULAR_ANUNCIO:
        {
            if (GetPlayerMoney(playerid) < 150) return SendClientMessage(playerid, COR_VERMELHO, "Voce precisa de $150 para anunciar.");
            if (strlen(inputtext) < 3) return SendClientMessage(playerid, COR_VERMELHO, "Anuncio muito curto.");

            GivePlayerMoney(playerid, -150);
            new an[160];
            format(an, sizeof(an), "[ANUNCIO] %s: %s", GetNome(playerid), inputtext);
            SendClientMessageToAll(COR_VERDE, an);
        }

        case DIALOG_EMPREGOS:
        {
            switch (listitem)
            {
                case 0: { PlayerInfo[playerid][pEmprego] = 1; SendClientMessage(playerid, COR_VERDE, "Agora voce e Entregador iFood!"); }
                case 1: { PlayerInfo[playerid][pEmprego] = 2; SendClientMessage(playerid, COR_VERDE, "Agora voce e Motorista de Onibus!"); }
                case 2: { PlayerInfo[playerid][pEmprego] = 3; SendClientMessage(playerid, COR_AZUL, "Agora voce e Policial Militar!"); }
                case 3: { PlayerInfo[playerid][pEmprego] = 4; SendClientMessage(playerid, COR_LARANJA, "Agora voce e Mecanico!"); }
                case 4: IniciarTrabalho(playerid);
                case 5: PararTrabalho(playerid);
            }
            SalvarConta(playerid);
        }

        case DIALOG_PREFEITURA:
        {
            switch (listitem)
            {
                case 0:
                {
                    if (PlayerInfo[playerid][pCNH] == 1) return SendClientMessage(playerid, COR_CINZA, "Voce ja tem CNH!");
                    if (GetPlayerMoney(playerid) < PRECO_CNH) return SendClientMessage(playerid, COR_VERMELHO, "Sem dinheiro ($1.200).");
                    GivePlayerMoney(playerid, -PRECO_CNH);
                    PlayerInfo[playerid][pCNH] = 1;
                    SalvarConta(playerid);
                    SendClientMessage(playerid, COR_VERDE, "CNH emitida com sucesso!");
                }
                case 1:
                {
                    ShowPlayerDialog(playerid, DIALOG_EMPREGOS, DIALOG_STYLE_LIST,
                        "{9B59B6}Empregos",
                        "Entregador iFood ($250/rota)\nMotorista de Onibus ($400/rota)\nPolicial Militar (Patrulha & Prisao)\nMecanico (Reparar Veiculos)\nIniciar Expediente\nEncerrar Expediente",
                        "Selecionar", "Voltar"
                    );
                }
                case 2:
                {
                    if (PlayerInfo[playerid][pFaccao] == 1)
                    {
                        PlayerInfo[playerid][pFaccao] = 0;
                        SendClientMessage(playerid, COR_CINZA, "Voce deixou a faccao Tropa ZK.");
                    }
                    else
                    {
                        PlayerInfo[playerid][pFaccao] = 1;
                        SendClientMessage(playerid, COR_ROXO_CLARO, "Bem-vindo a Tropa ZK! Use o GPS para ir ate o ponto do crime.");
                    }
                    SalvarConta(playerid);
                }
                case 3:
                {
                    if (PlayerInfo[playerid][pProcurado] == 0) return SendClientMessage(playerid, COR_CINZA, "Sem pendencias criminais.");
                    if (GetPlayerMoney(playerid) < 2000) return SendClientMessage(playerid, COR_VERMELHO, "Custa $2.000.");
                    GivePlayerMoney(playerid, -2000);
                    PlayerInfo[playerid][pProcurado] = 0;
                    SetPlayerWantedLevel(playerid, 0);
                    SendClientMessage(playerid, COR_VERDE, "Ficha limpa!");
                }
            }
        }

        case DIALOG_FACCAO:
        {
            if (PlayerInfo[playerid][pFaccao] != 1)
                return SendClientMessage(playerid, COR_VERMELHO, "Entre na faccao Tropa ZK na Prefeitura primeiro!");

            if (listitem == 0)
            {
                PlayerInfo[playerid][pDrogas] += 3;
                if (random(100) < 40)
                {
                    if (PlayerInfo[playerid][pProcurado] < 4) PlayerInfo[playerid][pProcurado]++;
                    SetPlayerWantedLevel(playerid, PlayerInfo[playerid][pProcurado]);
                    EnviarMensagemPolicia(COR_AZUL, "[COPOM] Atividade suspeita de drogas na zona sul!");
                }
                SendClientMessage(playerid, COR_ROXO_CLARO, "[CRIME] Voce produziu +3 cargas de drogas!");
            }
            else if (listitem == 1)
            {
                if (PlayerInfo[playerid][pDrogas] <= 0)
                    return SendClientMessage(playerid, COR_VERMELHO, "Voce nao tem cargas de drogas para vender.");
                new ganho = PlayerInfo[playerid][pDrogas] * 600;
                PlayerInfo[playerid][pDrogas] = 0;
                GivePlayerMoney(playerid, ganho);
                new msg[96];
                format(msg, sizeof(msg), "[CRIME] Carga vendida! Voce lucrou $%d sujos.", ganho);
                SendClientMessage(playerid, COR_VERDE, msg);
            }
        }

        case DIALOG_BANCO:
        {
            switch (listitem)
            {
                case 0: ShowPlayerDialog(playerid, DIALOG_BANCO_DEPOSITAR, DIALOG_STYLE_INPUT, "{2ECC71}Depositar", "Valor para depositar:", "Confirmar", "Voltar");
                case 1: ShowPlayerDialog(playerid, DIALOG_BANCO_SACAR, DIALOG_STYLE_INPUT, "{2ECC71}Sacar", "Valor para sacar:", "Confirmar", "Voltar");
                case 2: ShowPlayerDialog(playerid, DIALOG_BANCO_TRANSFERIR_ID, DIALOG_STYLE_INPUT, "{2ECC71}Transferir", "ID do jogador destino:", "Avancar", "Voltar");
            }
        }

        case DIALOG_BANCO_DEPOSITAR:
        {
            new v = strval(inputtext);
            if (v <= 0 || v > GetPlayerMoney(playerid)) return SendClientMessage(playerid, COR_VERMELHO, "Valor invalido.");
            GivePlayerMoney(playerid, -v);
            PlayerInfo[playerid][pBanco] += v;
            SalvarConta(playerid);
            SendClientMessage(playerid, COR_VERDE, "Deposito efetuado!");
        }

        case DIALOG_BANCO_SACAR:
        {
            new v = strval(inputtext);
            if (v <= 0 || v > PlayerInfo[playerid][pBanco]) return SendClientMessage(playerid, COR_VERMELHO, "Saldo insuficiente no banco.");
            PlayerInfo[playerid][pBanco] -= v;
            GivePlayerMoney(playerid, v);
            SalvarConta(playerid);
            SendClientMessage(playerid, COR_VERDE, "Saque efetuado!");
        }

        case DIALOG_BANCO_TRANSFERIR_ID:
        {
            new alvo = strval(inputtext);
            if (!IsPlayerConnected(alvo) || !PlayerInfo[alvo][pLogado] || alvo == playerid)
                return SendClientMessage(playerid, COR_VERMELHO, "ID invalido.");
            PlayerInfo[playerid][pAlvoTransferencia] = alvo;
            ShowPlayerDialog(playerid, DIALOG_BANCO_TRANSFERIR_VALOR, DIALOG_STYLE_INPUT, "{2ECC71}Valor da Transferencia", "Digite o valor (sai do banco):", "Transferir", "Cancelar");
        }

        case DIALOG_BANCO_TRANSFERIR_VALOR:
        {
            new v = strval(inputtext);
            new alvo = PlayerInfo[playerid][pAlvoTransferencia];
            if (v <= 0 || v > PlayerInfo[playerid][pBanco] || !IsPlayerConnected(alvo))
                return SendClientMessage(playerid, COR_VERMELHO, "Transferencia falhou.");

            PlayerInfo[playerid][pBanco] -= v;
            PlayerInfo[alvo][pBanco] += v;
            SalvarConta(playerid);
            SalvarConta(alvo);

            new m1[96], m2[96];
            format(m1, sizeof(m1), "[BANCO] Voce transferiu $%d para %s.", v, GetNome(alvo));
            format(m2, sizeof(m2), "[BANCO] Voce recebeu uma transferencia de $%d de %s.", v, GetNome(playerid));
            SendClientMessage(playerid, COR_VERDE, m1);
            SendClientMessage(alvo, COR_VERDE, m2);
        }

        case DIALOG_LOJA_247:
        {
            switch (listitem)
            {
                case 0:
                {
                    if (GetPlayerMoney(playerid) < 80) return SendClientMessage(playerid, COR_VERMELHO, "Sem dinheiro ($80).");
                    GivePlayerMoney(playerid, -80);
                    PlayerInfo[playerid][pComida] += 2;
                    SendClientMessage(playerid, COR_VERDE, "Comprado 2x Lanche! Use no Inventario.");
                }
                case 1:
                {
                    if (GetPlayerMoney(playerid) < 50) return SendClientMessage(playerid, COR_VERMELHO, "Sem dinheiro ($50).");
                    GivePlayerMoney(playerid, -50);
                    PlayerInfo[playerid][pAgua] += 2;
                    SendClientMessage(playerid, COR_VERDE, "Comprado 2x Agua! Use no Inventario.");
                }
                case 2:
                {
                    if (GetPlayerMoney(playerid) < 220) return SendClientMessage(playerid, COR_VERMELHO, "Sem dinheiro ($220).");
                    GivePlayerMoney(playerid, -220);
                    PlayerInfo[playerid][pKitMedico] += 1;
                    SendClientMessage(playerid, COR_VERDE, "Comprado 1x Kit Medico! Use no Inventario.");
                }
            }
            SalvarConta(playerid);
        }

        case DIALOG_POSTO:
        {
            if (!IsPlayerInAnyVehicle(playerid))
                return SendClientMessage(playerid, COR_VERMELHO, "Entre em um veiculo para abastecer ou reparar.");

            new vid = GetPlayerVehicleID(playerid);
            if (listitem == 0)
            {
                new falta = 100 - CombustivelVeh[vid];
                if (falta <= 0) return SendClientMessage(playerid, COR_CINZA, "O tanque ja esta cheio!");
                new custo = falta * PRECO_LITRO_GASOLINA;
                if (GetPlayerMoney(playerid) < custo) return SendClientMessage(playerid, COR_VERMELHO, "Dinheiro insuficiente para encher o tanque.");
                GivePlayerMoney(playerid, -custo);
                CombustivelVeh[vid] = 100;
                new msg[96];
                format(msg, sizeof(msg), "[POSTO] Tanque cheio por $%d!", custo);
                SendClientMessage(playerid, COR_VERDE, msg);
            }
            else if (listitem == 1)
            {
                if (GetPlayerMoney(playerid) < PRECO_REPARO_VEICULO)
                    return SendClientMessage(playerid, COR_VERMELHO, "Dinheiro insuficiente ($350).");
                GivePlayerMoney(playerid, -PRECO_REPARO_VEICULO);
                RepairVehicle(vid);
                SendClientMessage(playerid, COR_VERDE, "[OFICINA] Veiculo reparado com sucesso!");
            }
        }

        case DIALOG_ROUPAS:
        {
            if (GetPlayerMoney(playerid) < PRECO_ROUPA) return SendClientMessage(playerid, COR_VERMELHO, "Sem dinheiro ($500).");
            GivePlayerMoney(playerid, -PRECO_ROUPA);
            PlayerInfo[playerid][pSkin] = SkinLoja[listitem];
            SetPlayerSkin(playerid, SkinLoja[listitem]);
            SalvarConta(playerid);
            SendClientMessage(playerid, COR_VERDE, "Roupa equipada e salva!");
        }

        case DIALOG_CONCESSIONARIA:
        {
            if (GetPlayerMoney(playerid) < PrecoVeiculo[listitem]) return SendClientMessage(playerid, COR_VERMELHO, "Dinheiro insuficiente.");

            if (PlayerInfo[playerid][pVehSpawnado])
            {
                DestroyVehicle(PlayerInfo[playerid][pVehID]);
                PlayerInfo[playerid][pVehSpawnado] = false;
            }

            GivePlayerMoney(playerid, -PrecoVeiculo[listitem]);
            PlayerInfo[playerid][pVehModelo] = ModeloVeiculo[listitem];

            new Float:x, Float:y, Float:z, Float:a;
            GetPlayerPos(playerid, x, y, z);
            GetPlayerFacingAngle(playerid, a);

            PlayerInfo[playerid][pVehID] = CriarVeiculoComCombustivel(ModeloVeiculo[listitem], x + 3.0, y, z, a, -1, -1);
            PlayerInfo[playerid][pVehSpawnado] = true;
            PutPlayerInVehicle(playerid, PlayerInfo[playerid][pVehID], 0);
            SalvarConta(playerid);

            new msg[96];
            format(msg, sizeof(msg), "[CONCESSIONARIA] Voce comprou um(a) %s!", NomeVeiculo[listitem]);
            SendClientMessage(playerid, COR_VERDE, msg);
        }

        case DIALOG_VEICULO_MENU:
        {
            switch (listitem)
            {
                case 0:
                {
                    if (PlayerInfo[playerid][pVehSpawnado])
                    {
                        DestroyVehicle(PlayerInfo[playerid][pVehID]);
                        PlayerInfo[playerid][pVehSpawnado] = false;
                        SendClientMessage(playerid, COR_CINZA, "Veiculo guardado na garagem.");
                    }
                    else
                    {
                        new Float:x, Float:y, Float:z, Float:a;
                        GetPlayerPos(playerid, x, y, z);
                        GetPlayerFacingAngle(playerid, a);
                        PlayerInfo[playerid][pVehID] = CriarVeiculoComCombustivel(PlayerInfo[playerid][pVehModelo], x + 2.5, y, z, a, -1, -1);
                        PlayerInfo[playerid][pVehSpawnado] = true;
                        SendClientMessage(playerid, COR_VERDE, "Veiculo retirado da garagem!");
                    }
                }
                case 1:
                {
                    if (!PlayerInfo[playerid][pVehSpawnado]) return SendClientMessage(playerid, COR_VERMELHO, "Retire o veiculo primeiro.");
                    PlayerInfo[playerid][pVehTrancado] = !PlayerInfo[playerid][pVehTrancado];
                    new e, l, a, d, bo, b, o;
                    GetVehicleParamsEx(PlayerInfo[playerid][pVehID], e, l, a, d, bo, b, o);
                    SetVehicleParamsEx(PlayerInfo[playerid][pVehID], e, l, a, PlayerInfo[playerid][pVehTrancado], bo, b, o);
                    SendClientMessage(playerid, COR_AZUL, PlayerInfo[playerid][pVehTrancado] ? "Veiculo trancado." : "Veiculo destrancado.");
                }
                case 2:
                {
                    if (!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COR_VERMELHO, "Entre no veiculo.");
                    new vid = GetPlayerVehicleID(playerid);
                    if (CombustivelVeh[vid] <= 0) return SendClientMessage(playerid, COR_VERMELHO, "Sem combustivel!");
                    MotorLigadoVeh[vid] = !MotorLigadoVeh[vid];
                    new e, l, a, d, bo, b, o;
                    GetVehicleParamsEx(vid, e, l, a, d, bo, b, o);
                    SetVehicleParamsEx(vid, MotorLigadoVeh[vid] ? 1 : 0, l, a, d, bo, b, o);
                    SendClientMessage(playerid, COR_DOURADO, MotorLigadoVeh[vid] ? "Motor ligado!" : "Motor desligado.");
                }
                case 3:
                {
                    if (!PlayerInfo[playerid][pVehSpawnado]) return SendClientMessage(playerid, COR_VERMELHO, "Veiculo esta guardado.");
                    new Float:vx, Float:vy, Float:vz;
                    GetVehiclePos(PlayerInfo[playerid][pVehID], vx, vy, vz);
                    SetPlayerCheckpoint(playerid, vx, vy, vz, 4.0);
                    SendClientMessage(playerid, COR_LARANJA, "Localizacao do veiculo marcada!");
                }
            }
        }

        case DIALOG_CASA:
        {
            new c = PlayerInfo[playerid][pCasaAtual];
            if (c < 0 || c >= MAX_CASAS) return 1;

            if (Casas[c][cComprada] && !strcmp(Casas[c][cDono], GetNome(playerid), true))
            {
                if (listitem == 0)
                {
                    if (Casas[c][cTrancada]) return SendClientMessage(playerid, COR_VERMELHO, "Destranque a casa primeiro.");
                    PlayerInfo[playerid][pDentroCasa] = true;
                    SetPlayerInterior(playerid, 1);
                    SetPlayerVirtualWorld(playerid, c + 10);
                    SetPlayerPos(playerid, 223.0, 1287.0, 1082.1);
                }
                else if (listitem == 1)
                {
                    Casas[c][cTrancada] = !Casas[c][cTrancada];
                    SalvarCasas();
                    SendClientMessage(playerid, COR_VERDE, Casas[c][cTrancada] ? "Casa trancada." : "Casa destrancada.");
                }
                else if (listitem == 2)
                {
                    GivePlayerMoney(playerid, Casas[c][cPreco] / 2);
                    Casas[c][cComprada] = false;
                    Casas[c][cTrancada] = false;
                    format(Casas[c][cDono], MAX_PLAYER_NAME, "Ninguem");
                    SalvarCasas();
                    SendClientMessage(playerid, COR_VERDE, "Casa vendida!");
                }
            }
            else if (!Casas[c][cComprada])
            {
                if (GetPlayerMoney(playerid) < Casas[c][cPreco]) return SendClientMessage(playerid, COR_VERMELHO, "Dinheiro insuficiente.");
                GivePlayerMoney(playerid, -Casas[c][cPreco]);
                Casas[c][cComprada] = true;
                format(Casas[c][cDono], MAX_PLAYER_NAME, "%s", GetNome(playerid));
                SalvarCasas();
                SendClientMessage(playerid, COR_VERDE, "Casa comprada com sucesso!");
            }
            else
            {
                if (listitem == 1 && !Casas[c][cTrancada])
                {
                    PlayerInfo[playerid][pDentroCasa] = true;
                    SetPlayerInterior(playerid, 1);
                    SetPlayerVirtualWorld(playerid, c + 10);
                    SetPlayerPos(playerid, 223.0, 1287.0, 1082.1);
                }
                else SendClientMessage(playerid, COR_VERMELHO, "Casa trancada ou pertence a outro jogador.");
            }
        }

        case DIALOG_POLICIA:
        {
            if (listitem == 0)
            {
                SetPlayerArmour(playerid, 100.0);
                GivePlayerWeapon(playerid, 3, 1);
                GivePlayerWeapon(playerid, 24, 120);
                GivePlayerWeapon(playerid, 29, 240);
                SendClientMessage(playerid, COR_AZUL, "[PM] Armamento equipado!");
            }
            else if (listitem == 1 || listitem == 2)
            {
                new Float:px, Float:py, Float:pz, alvo = INVALID_PLAYER_ID;
                GetPlayerPos(playerid, px, py, pz);

                for (new i = 0; i < MAX_PLAYERS; i++)
                {
                    if (i != playerid && IsPlayerConnected(i) && PlayerInfo[i][pProcurado] > 0)
                    {
                        if (IsPlayerInRangeOfPoint(i, 8.0, px, py, pz)) { alvo = i; break; }
                    }
                }
                if (alvo == INVALID_PLAYER_ID) return SendClientMessage(playerid, COR_CINZA, "Nenhum procurado perto.");

                if (listitem == 1)
                {
                    new msg[96];
                    format(msg, sizeof(msg), "[PM] %s esta procurado (%d estrelas).", GetNome(alvo), PlayerInfo[alvo][pProcurado]);
                    SendClientMessage(playerid, COR_AZUL, msg);
                }
                else
                {
                    PlayerInfo[alvo][pProcurado] = 0;
                    SetPlayerWantedLevel(alvo, 0);
                    SetPlayerPos(alvo, 264.6, 77.5, 1001.0);
                    SetPlayerInterior(alvo, 6);
                    GivePlayerMoney(playerid, 1000);
                    SendClientMessage(playerid, COR_VERDE, "[PM] Suspeito preso! +$1.000 de recompensa.");
                    SendClientMessage(alvo, COR_VERMELHO, "[PRISAO] Voce foi detido pela PM!");
                }
            }
        }

        // --- PAINEL DO DONO ---
        case DIALOG_DONO_LOGIN:
        {
            if (!PlayerInfo[playerid][pEhDono]) return 1;
            if (strcmp(inputtext, SENHA_DONO, false) == 0)
            {
                PlayerInfo[playerid][pAutenticadoDono] = true;
                MostrarPainelDono(playerid);
            }
            else SendClientMessage(playerid, COR_VERMELHO, "Senha incorreta.");
        }

        case DIALOG_DONO_PAINEL:
        {
            if (!PlayerInfo[playerid][pEhDono] || !PlayerInfo[playerid][pAutenticadoDono]) return 1;
            switch (listitem)
            {
                case 0: ShowPlayerDialog(playerid, DIALOG_DONO_VEICULOS, DIALOG_STYLE_LIST, "{F1C40F}Spawnar Veiculo", "Infernus\nNRG-500\nElegy\nTurismo\nMaverick", "Criar", "Voltar");
                case 1: ShowPlayerDialog(playerid, DIALOG_DONO_TELEPORTES, DIALOG_STYLE_LIST, "{F1C40F}Teleportes", "Prefeitura\nBanco\nConcessionaria\nLoja Roupas\nMercado 24/7\nPosto\nPonto Crime", "Ir", "Voltar");
                case 2:
                {
                    SetPlayerHealth(playerid, 100.0);
                    SetPlayerArmour(playerid, 100.0);
                    GivePlayerMoney(playerid, 100000);
                    PlayerInfo[playerid][pFome] = 100;
                    PlayerInfo[playerid][pSede] = 100;
                    SendClientMessage(playerid, COR_DOURADO, "[DONO] Status restaurado + $100.000!");
                }
                case 3: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
                case 4:
                {
                    SendClientMessageToAll(COR_DOURADO, "[EVENTO] PayDay Bonus ativado pelo Dono: +$2.500 no banco e +2 XP!");
                    for (new i = 0; i < MAX_PLAYERS; i++)
                    {
                        if (IsPlayerConnected(i) && PlayerInfo[i][pLogado])
                        {
                            PlayerInfo[i][pBanco] += 2500;
                            PlayerInfo[i][pXP] += 2;
                        }
                    }
                }
            }
        }

        case DIALOG_DONO_VEICULOS:
        {
            if (!PlayerInfo[playerid][pEhDono] || !PlayerInfo[playerid][pAutenticadoDono]) return 1;
            new Float:x, Float:y, Float:z, Float:a;
            GetPlayerPos(playerid, x, y, z);
            GetPlayerFacingAngle(playerid, a);
            new v = CriarVeiculoComCombustivel(ModeloDono[listitem], x + 3.0, y, z, a, -1, -1);
            PutPlayerInVehicle(playerid, v, 0);
        }

        case DIALOG_DONO_TELEPORTES:
        {
            if (!PlayerInfo[playerid][pEhDono] || !PlayerInfo[playerid][pAutenticadoDono]) return 1;
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
            switch (listitem)
            {
                case 0: SetPlayerPos(playerid, POS_SPAWN_X, POS_SPAWN_Y, POS_SPAWN_Z);
                case 1: SetPlayerPos(playerid, POS_BANCO_X, POS_BANCO_Y, POS_BANCO_Z);
                case 2: SetPlayerPos(playerid, POS_CONCE_X, POS_CONCE_Y, POS_CONCE_Z);
                case 3: SetPlayerPos(playerid, POS_ROUPAS_X, POS_ROUPAS_Y, POS_ROUPAS_Z);
                case 4: SetPlayerPos(playerid, POS_LOJA247_X, POS_LOJA247_Y, POS_LOJA247_Z);
                case 5: SetPlayerPos(playerid, POS_POSTO_X, POS_POSTO_Y, POS_POSTO_Z);
                case 6: SetPlayerPos(playerid, POS_DROGA_X, POS_DROGA_Y, POS_DROGA_Z);
            }
        }
    }
    return 1;
}

stock MostrarPainelDono(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_DONO_PAINEL, DIALOG_STYLE_LIST,
        "{F1C40F}ZK RP - Painel do Dono",
        "Criar Veiculo\nTeleportes\nVida, Colete, Fome/Sede + $100k\nJetpack\nPayDay Bonus Global",
        "Selecionar", "Fechar"
    );
}

// ============================================================================
// CHECKPOINTS, CONDUCAO E TIMERS
// ============================================================================

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if (newstate == PLAYER_STATE_DRIVER)
    {
        if (PlayerInfo[playerid][pCNH] == 0 && !PlayerInfo[playerid][pEhDono])
            SendClientMessage(playerid, COR_LARANJA, "[TRANSITO] Dirigindo sem CNH! Va a Prefeitura tirar sua habilitacao.");

        new vid = GetPlayerVehicleID(playerid);
        if (vid > 0 && vid < MAX_VEICULOS_SERVIDOR && CombustivelVeh[vid] == 0 && !MotorLigadoVeh[vid])
            CombustivelVeh[vid] = 50; // Garante combustivel inicial caso seja veiculo nativo do mapa
    }
    return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if (!PlayerInfo[playerid][pTrabalhando])
    {
        DisablePlayerCheckpoint(playerid);
        SendClientMessage(playerid, COR_VERDE, "[GPS] Destino alcancado!");
        return 1;
    }

    new emp = PlayerInfo[playerid][pEmprego];
    new etapa = PlayerInfo[playerid][pEtapaTrabalho];

    if (emp == 1)
    {
        GivePlayerMoney(playerid, 250);
        SendClientMessage(playerid, COR_VERDE, "[iFood] Entrega concluida! +$250.");
        etapa = (etapa + 1 >= 5) ? 0 : etapa + 1;
        PlayerInfo[playerid][pEtapaTrabalho] = etapa;
        SetPlayerCheckpoint(playerid, RotaEntregador[etapa][0], RotaEntregador[etapa][1], RotaEntregador[etapa][2], 4.0);
    }
    else if (emp == 2)
    {
        GivePlayerMoney(playerid, 400);
        SendClientMessage(playerid, COR_VERDE, "[ONIBUS] Parada concluida! +$400.");
        etapa = (etapa + 1 >= 5) ? 0 : etapa + 1;
        PlayerInfo[playerid][pEtapaTrabalho] = etapa;
        SetPlayerCheckpoint(playerid, RotaOnibus[etapa][0], RotaOnibus[etapa][1], RotaOnibus[etapa][2], 5.0);
    }
    return 1;
}

public TimerGeralServidor()
{
    static seg = 0;
    seg++;

    // Consumo gradual de combustivel a cada 5s
    if (seg % 5 == 0)
    {
        for (new v = 1; v < MAX_VEICULOS_SERVIDOR; v++)
        {
            if (CombustivelVeh[v] > 0)
            {
                // Verifica se ha motorista dirigindo
                for (new p = 0; p < MAX_PLAYERS; p++)
                {
                    if (IsPlayerConnected(p) && GetPlayerState(p) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(p) == v)
                    {
                        if (GetVelocidadeKMH(p) > 5)
                        {
                            CombustivelVeh[v]--;
                            if (CombustivelVeh[v] <= 0)
                            {
                                CombustivelVeh[v] = 0;
                                MotorLigadoVeh[v] = false;
                                SendClientMessage(p, COR_VERMELHO, "[COMBUSTIVEL] Acabou a gasolina! Va ao Posto (use o GPS).");
                            }
                        }
                        break;
                    }
                }
            }
        }
    }

    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (!IsPlayerConnected(i) || !PlayerInfo[i][pLogado]) continue;

        AtualizarTextoHUD(i);

        if (seg >= 60)
        {
            PlayerInfo[i][pMinutosJogados]++;
            if (PlayerInfo[i][pMinutosJogados] >= TEMPO_PAYDAY_MINUTOS)
            {
                PlayerInfo[i][pMinutosJogados] = 0;
                PlayerInfo[i][pBanco] += 900;
                PlayerInfo[i][pXP]++;

                SendClientMessage(i, COR_DOURADO, "========== [ PAYDAY ZK RP ] ==========");
                SendClientMessage(i, COR_VERDE, "Salario de $900 depositado no banco + 1 XP!");

                if (PlayerInfo[i][pXP] >= 5)
                {
                    PlayerInfo[i][pXP] = 0;
                    PlayerInfo[i][pNivel]++;
                    SetPlayerScore(i, PlayerInfo[i][pNivel]);
                    SendClientMessage(i, COR_ROXO_CLARO, "PARABENS! Voce alcancou um novo nivel!");
                }
                SalvarConta(i);
            }
        }
    }

    if (seg >= 60) seg = 0;
    return 1;
}

public TimerFomeSede()
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (!IsPlayerConnected(i) || !PlayerInfo[i][pLogado]) continue;

        if (PlayerInfo[i][pFome] > 0) PlayerInfo[i][pFome] -= 5;
        if (PlayerInfo[i][pSede] > 0) PlayerInfo[i][pSede] -= 6;
        if (PlayerInfo[i][pFome] < 0) PlayerInfo[i][pFome] = 0;
        if (PlayerInfo[i][pSede] < 0) PlayerInfo[i][pSede] = 0;

        if (PlayerInfo[i][pFome] <= 15 || PlayerInfo[i][pSede] <= 15)
        {
            new Float:hp;
            GetPlayerHealth(i, hp);
            SetPlayerHealth(i, hp - 5.0);
            SendClientMessage(i, COR_VERMELHO, "[STATUS] Fome ou sede critica! Use o Inventario ou va ao Mercado 24/7.");
        }
    }
    return 1;
}

// ============================================================================
// COMANDOS RAPIDOS
// ============================================================================

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!PlayerInfo[playerid][pLogado]) return 0;

    if (!strcmp(cmdtext, "/menu", true)) { MostrarMenuPrincipal(playerid); return 1; }
    if (!strcmp(cmdtext, "/acao", true) || !strcmp(cmdtext, "/interagir", true)) { ProcessarInteracaoContextual(playerid); return 1; }
    if (!strcmp(cmdtext, "/v", true) || !strcmp(cmdtext, "/veiculo", true)) { MostrarMenuVeiculo(playerid); return 1; }
    if (!strcmp(cmdtext, "/gps", true)) { MostrarMenuGPS(playerid); return 1; }
    if (!strcmp(cmdtext, "/fone", true) || !strcmp(cmdtext, "/celular", true)) { MostrarMenuCelular(playerid); return 1; }
    if (!strcmp(cmdtext, "/inv", true) || !strcmp(cmdtext, "/inventario", true)) { MostrarInventario(playerid); return 1; }
    if (!strcmp(cmdtext, "/parar", true)) { PararTrabalho(playerid); return 1; }

    if (!strcmp(cmdtext, "/reparar", true))
    {
        if (PlayerInfo[playerid][pEmprego] != 4)
            return SendClientMessage(playerid, COR_VERMELHO, "Apenas Mecanicos podem usar /reparar!");

        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        for (new v = 1; v < MAX_VEICULOS_SERVIDOR; v++)
        {
            if (IsPlayerInRangeOfPoint(playerid, 5.0, x, y, z))
            {
                new Float:vx, Float:vy, Float:vz;
                GetVehiclePos(v, vx, vy, vz);
                if (IsPlayerInRangeOfPoint(playerid, 5.0, vx, vy, vz))
                {
                    RepairVehicle(v);
                    GivePlayerMoney(playerid, 200);
                    SendClientMessage(playerid, COR_VERDE, "[MECANICO] Veiculo reparado! Voce ganhou $200.");
                    return 1;
                }
            }
        }
        return SendClientMessage(playerid, COR_VERMELHO, "Nenhum veiculo proximo.");
    }

    if (!strcmp(cmdtext, "/assaltar", true))
    {
        new Float:px, Float:py, Float:pz, alvo = INVALID_PLAYER_ID;
        GetPlayerPos(playerid, px, py, pz);
        for (new i = 0; i < MAX_PLAYERS; i++)
        {
            if (i != playerid && IsPlayerConnected(i) && PlayerInfo[i][pLogado])
            {
                if (IsPlayerInRangeOfPoint(i, 3.5, px, py, pz)) { alvo = i; break; }
            }
        }
        if (alvo == INVALID_PLAYER_ID) return SendClientMessage(playerid, COR_VERMELHO, "Ninguem por perto para assaltar.");
        new grana = GetPlayerMoney(alvo);
        if (grana < 100) return SendClientMessage(playerid, COR_CINZA, "O alvo nao tem dinheiro suficiente.");

        new roubo = grana / 4;
        GivePlayerMoney(alvo, -roubo);
        GivePlayerMoney(playerid, roubo);

        if (PlayerInfo[playerid][pProcurado] < 5) PlayerInfo[playerid][pProcurado]++;
        SetPlayerWantedLevel(playerid, PlayerInfo[playerid][pProcurado]);
        EnviarMensagemPolicia(COR_AZUL, "[190] Assalto em andamento na cidade!");

        new m1[96], m2[96];
        format(m1, sizeof(m1), "[ASSALTO] Voce roubou $%d de %s!", roubo, GetNome(alvo));
        format(m2, sizeof(m2), "[ASSALTO] Voce foi assaltado e perdeu $%d!", roubo);
        SendClientMessage(playerid, COR_DOURADO, m1);
        SendClientMessage(alvo, COR_VERMELHO, m2);
        return 1;
    }

    if (!strcmp(cmdtext, "/dono", true))
    {
        if (!PlayerInfo[playerid][pEhDono]) return SendClientMessage(playerid, COR_VERMELHO, "Acesso negado.");
        ShowPlayerDialog(playerid, DIALOG_DONO_LOGIN, DIALOG_STYLE_PASSWORD, "{F1C40F}Acesso do Dono", "Digite sua senha:", "Entrar", "Cancelar");
        return 1;
    }

    if (!strcmp(cmdtext, "/g ", true, 3))
    {
        if (strlen(cmdtext) <= 3) return SendClientMessage(playerid, COR_CINZA, "Use: /g [mensagem]");
        new msg[144];
        format(msg, sizeof(msg), "%s grita: %s!", GetNome(playerid), cmdtext[3]);
        EnviarMensagemLocal(playerid, 35.0, COR_DOURADO, msg);
        return 1;
    }

    if (!strcmp(cmdtext, "/s ", true, 3))
    {
        if (strlen(cmdtext) <= 3) return SendClientMessage(playerid, COR_CINZA, "Use: /s [mensagem]");
        new msg[144];
        format(msg, sizeof(msg), "%s sussurra: %s", GetNome(playerid), cmdtext[3]);
        EnviarMensagemLocal(playerid, 6.0, COR_CINZA, msg);
        return 1;
    }

    if (!strcmp(cmdtext, "/me ", true, 4))
    {
        if (strlen(cmdtext) <= 4) return SendClientMessage(playerid, COR_CINZA, "Use: /me [acao]");
        new msg[144];
        format(msg, sizeof(msg), "* %s %s", GetNome(playerid), cmdtext[4]);
        EnviarMensagemLocal(playerid, 20.0, COR_ROXO_CLARO, msg);
        return 1;
    }

    if (!strcmp(cmdtext, "/do ", true, 4))
    {
        if (strlen(cmdtext) <= 4) return SendClientMessage(playerid, COR_CINZA, "Use: /do [situacao]");
        new msg[144];
        format(msg, sizeof(msg), "* %s (( %s ))", cmdtext[4], GetNome(playerid));
        EnviarMensagemLocal(playerid, 20.0, COR_VERDE, msg);
        return 1;
    }

    if (!strcmp(cmdtext, "/ajuda", true))
    {
        SendClientMessage(playerid, COR_ROXO, "=== ZK RP v3.0 - COMANDOS ===");
        SendClientMessage(playerid, COR_BRANCO, "Botoes na tela: MENU, ACAO, CARRO, GPS, FONE.");
        SendClientMessage(playerid, COR_CINZA, "Comandos: /inv, /g, /s, /me, /do, /assaltar, /reparar, /parar.");
        return 1;
    }

    return 0;
}
