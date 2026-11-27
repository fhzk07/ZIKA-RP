#include <a_samp>

// ============================================================================
// ZK RP v3.0 - GAMEMODE MOBILE
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
    pEmprego,
    pFaccao,
    pDrogas,
    pKitMedico,
    pComida,
    pAgua,
    pProcurado,
    pMinutosJogados,
    pAlvoTransferencia,
    pAlvoSMS,
    pVehModelo,
    pVehCor1,
    pVehCor2,
    pVehID,
    bool:pVehSpawnado,
    bool:pVehTrancado,
    bool:pTrabalhando,
    pVehTrabalho,
    pEtapaTrabalho,
    bool:pDentroCasa,
    pCasaAtual,
    pUltimoAnuncio
};

new PlayerInfo[MAX_PLAYERS][E_PLAYER_DATA];

// Cache de nomes: evita retornar arrays locais de funcoes.
new NomeCache[MAX_PLAYERS][MAX_PLAYER_NAME];

#define GetNome(%0) NomeCache[%0]

// Nomes fixos usados pelo HUD e pelo RG.
new const NomeEmprego[5][28] = {
    "Desempregado",
    "Entregador iFood",
    "Motorista de Onibus",
    "Policial Militar",
    "Mecanico"
};

new const NomeFaccao[2][24] = {
    "Cidadao Civil",
    "Tropa ZK (Crime)"
};

#define ObterNomeEmprego(%0) NomeEmprego[%0]
#define ObterNomeFaccao(%0) NomeFaccao[%0]

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
new const NomeVeiculo[6][24] = {
    "Faggio", "Sanchez", "Elegy", "Bullet", "Landstalker", "Infernus"
};
new const PrecoVeiculo[6] = {1500, 3000, 12000, 25000, 15000, 45000};
new const ModeloDono[5] = {411, 522, 560, 451, 487};

// --- FORWARDS ---
forward TimerGeralServidor();
forward TimerFomeSede();

// ============================================================================
// UTILITARIOS E SALVAMENTO
// ============================================================================

stock bool:VerificarDono(playerid)
{
    return (!strcmp(NomeCache[playerid], NOME_DONO, true));
}

stock RemoverQuebra(str[])
{
    for (new i = 0; str[i] != '\0'; i++)
    {
        if (str[i] == '\r' || str[i] == '\n')
        {
            str[i] = '\0';
        }
    }
    return 1;
}

stock CaminhoConta(playerid, dest[], len)
{
    format(dest, len, "Contas/%s.ini", NomeCache[playerid]);
    return 1;
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

        if (!strcmp(chave, "Senha"))
            format(PlayerInfo[playerid][pSenha], 32, "%s", valor);
        else if (!strcmp(chave, "Dinheiro"))
            PlayerInfo[playerid][pDinheiro] = strval(valor);
        else if (!strcmp(chave, "Banco"))
            PlayerInfo[playerid][pBanco] = strval(valor);
        else if (!strcmp(chave, "Nivel"))
            PlayerInfo[playerid][pNivel] = strval(valor);
        else if (!strcmp(chave, "XP"))
            PlayerInfo[playerid][pXP] = strval(valor);
        else if (!strcmp(chave, "Skin"))
            PlayerInfo[playerid][pSkin] = strval(valor);
        else if (!strcmp(chave, "Fome"))
            PlayerInfo[playerid][pFome] = strval(valor);
        else if (!strcmp(chave, "Sede"))
            PlayerInfo[playerid][pSede] = strval(valor);
        else if (!strcmp(chave, "CNH"))
            PlayerInfo[playerid][pCNH] = strval(valor);
        else if (!strcmp(chave, "Emprego"))
            PlayerInfo[playerid][pEmprego] = strval(valor);
        else if (!strcmp(chave, "Faccao"))
            PlayerInfo[playerid][pFaccao] = strval(valor);
        else if (!strcmp(chave, "Drogas"))
            PlayerInfo[playerid][pDrogas] = strval(valor);
        else if (!strcmp(chave, "KitMedico"))
            PlayerInfo[playerid][pKitMedico] = strval(valor);
        else if (!strcmp(chave, "Comida"))
            PlayerInfo[playerid][pComida] = strval(valor);
        else if (!strcmp(chave, "Agua"))
            PlayerInfo[playerid][pAgua] = strval(valor);
        else if (!strcmp(chave, "Procurado"))
            PlayerInfo[playerid][pProcurado] = strval(valor);
        else if (!strcmp(chave, "VehModelo"))
            PlayerInfo[playerid][pVehModelo] = strval(valor);
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
        format(linha, sizeof(linha), "%d|%s|%d|%d\r\n",
            i,
            Casas[i][cDono],
            Casas[i][cComprada] ? 1 : 0,
            Casas[i][cTrancada] ? 1 : 0
        );
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

        strmid(tmp, linha, 0, p1);
        idx = strval(tmp);

        if (idx < 0 || idx >= MAX_CASAS) continue;

        strmid(dono, linha, p1 + 1, p2);

        strmid(tmp, linha, p2 + 1, p3);
        comp = strval(tmp);

        strmid(tmp, linha, p3 + 1, strlen(linha));
        tranc = strval(tmp);

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
            if (IsPlayerInRangeOfPoint(i, raio, x, y, z) &&
                GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))
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
        if (IsPlayerConnected(i) &&
            PlayerInfo[i][pLogado] &&
            PlayerInfo[i][pEmprego] == 3)
        {
            SendClientMessage(i, cor, texto);
        }
    }
    return 1;
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

    new Float:vel = floatsqroot(
        (vx * vx) + (vy * vy) + (vz * vz)
    ) * 180.0;

    return floatround(vel);
}

// ============================================================================
// HUD E BOTOES MOBILE
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
    if (!IsPlayerConnected(playerid) ||
        !HUDCriado[playerid] ||
        !PlayerInfo[playerid][pLogado])
    {
        return 1;
    }

    new texto[180], status[150];
    new tag[16];
    tag[0] = '\0';

    if (PlayerInfo[playerid][pEhDono])
    {
        format(tag, sizeof(tag), "[DONO] ");
    }

    format(texto, sizeof(texto),
        "~p~ZK RP~w~ | %s%s (Nv.%d)~n~~g~Mao: $%d ~w~| ~b~Banco: $%d",
        tag,
        GetNome(playerid),
        PlayerInfo[playerid][pNivel],
        GetPlayerMoney(playerid),
        PlayerInfo[playerid][pBanco]
    );

    PlayerTextDrawSetString(playerid, HUDInfo[playerid], texto);

    new emprego = PlayerInfo[playerid][pEmprego];
    if (emprego < 0 || emprego > 4) emprego = 0;

    format(status, sizeof(status),
        "~y~Fome:~w~ %d%%~n~~b~Sede:~w~ %d%%~n~~p~Cargo:~w~ %s",
        PlayerInfo[playerid][pFome],
        PlayerInfo[playerid][pSede],
        NomeEmprego[emprego]
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

        format(velStr, sizeof(velStr),
            "~w~VEL: ~p~%d KM/H~n~~y~COMBUSTIVEL: ~w~%d%%",
            GetVelocidadeKMH(playerid),
            CombustivelVeh[vid]
        );

        PlayerTextDrawSetString(playerid, HUDVelocimetro[playerid], velStr);
    }
    else if (VelocimetroVisivel[playerid])
    {
        PlayerTextDrawHide(playerid, HUDVelocimetro[playerid]);
        VelocimetroVisivel[playerid] = false;
    }

    return 1;
}

// Parametro de texto sem const para compatibilidade com TextDrawCreate.
stock CriarBotaoMobile(Float:x, Float:y, texto[], corBox)
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

    BtnMenu = CriarBotaoMobile(12.0, 355.0, " MENU", COR_ROXO);
    BtnInteragir = CriarBotaoMobile(64.0, 355.0, "  ACAO", COR_VERDE);
    BtnVeiculo = CriarBotaoMobile(116.0, 355.0, "CARRO", COR_AZUL);
    BtnGPS = CriarBotaoMobile(168.0, 355.0, "  GPS", COR_LARANJA);
    BtnCelular = CriarBotaoMobile(220.0, 355.0, "FONE", COR_CIANO);

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
        {
            format(label, sizeof(label),
                "{9B59B6}[CASA #%d]\n{FFFFFF}Dono: %s\nToque em ACAO",
                i + 1,
                Casas[i][cDono]
            );
        }
        else
        {
            format(label, sizeof(label),
                "{9B59B6}[CASA #%d A VENDA]\n{2ECC71}Valor: $%d\n{FFFFFF}Toque em ACAO",
                i + 1,
                Casas[i][cPreco]
            );
        }

        Create3DTextLabel(label, COR_BRANCO,
            Casas[i][cX],
            Casas[i][cY],
            Casas[i][cZ] + 0.5,
            12.0,
            0
        );
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
        if (IsPlayerConnected(i) && PlayerInfo[i][pLogado])
        {
            SalvarConta(i);
        }
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

GetPlayerName(playerid, NomeCache[playerid], MAX_PLAYER_NAME);
{
    // Limpa todos os campos da estrutura, incluindo o array da senha.
    for (new j = 0; j < sizeof(PlayerInfo[]); j++)
    {
        PlayerInfo[playerid][j] = 0;
    }

    // O nome precisa ser carregado antes da verificacao de dono e da conta.
    GetPlayerName(NomeCache[playerid], playerid, MAX_PLAYER_NAME);
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
    VelocimetroVisivel[playerid] = false;

    TogglePlayerClock(playerid, 0);
    SetPlayerColor(playerid, COR_BRANCO);

    for (new i = 0; i < 12; i++)
    {
        SendClientMessage(playerid, -1, " ");
    }

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
    if (PlayerInfo[playerid][pLogado])
    {
        SalvarConta(playerid);
    }

    if (HUDCriado[playerid])
    {
        PlayerTextDrawDestroy(playerid, HUDInfo[playerid]);
        PlayerTextDrawDestroy(playerid, HUDStatus[playerid]);
        PlayerTextDrawDestroy(playerid, HUDVelocimetro[playerid]);

        HUDCriado[playerid] = false;
    }

    if (PlayerInfo[playerid][pTrabalhando] &&
        PlayerInfo[playerid][pVehTrabalho] != 0)
    {
        DestroyVehicle(PlayerInfo[playerid][pVehTrabalho]);
    }

    if (PlayerInfo[playerid][pVehSpawnado])
    {
        DestroyVehicle(PlayerInfo[playerid][pVehID]);
    }

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
        SendClientMessage(playerid, COR_DOURADO,
            "[DONO] Acesso liberado. Use /dono para abrir o painel."
        );
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
    if (PlayerInfo[playerid][pTrabalhando])
    {
        PararTrabalho(playerid);
    }

    if (killerid != INVALID_PLAYER_ID && IsPlayerConnected(killerid))
    {
        if (PlayerInfo[killerid][pEmprego] != 3)
        {
            if (PlayerInfo[killerid][pProcurado] < 6)
            {
                PlayerInfo[killerid][pProcurado]++;
            }

            SetPlayerWantedLevel(killerid, PlayerInfo[killerid][pProcurado]);

            SendClientMessage(killerid, COR_VERMELHO,
                "[PROCURADO] Voce cometeu um homicidio e sua estrela aumentou!"
            );

            EnviarMensagemPolicia(COR_AZUL,
                "[COPOM] Denuncia de homicidio na cidade! Fiquem atentos."
            );
        }
    }

    if (GetPlayerMoney(playerid) >= 200)
    {
        GivePlayerMoney(playerid, -200);
        SendClientMessage(playerid, COR_VERMELHO,
            "[HOSPITAL] Taxa medica de $200 descontada."
        );
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
    {
        format(msg, sizeof(msg),
            "{F1C40F}[DONO] {FFFFFF}%s diz: %s",
            GetNome(playerid),
            text
        );
    }
    else
    {
        format(msg, sizeof(msg),
            "%s diz: %s",
            GetNome(playerid),
            text
        );
    }

    EnviarMensagemLocal(playerid, 20.0, COR_BRANCO, msg);
    return 0;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if (_:clickedid == INVALID_TEXT_DRAW)
    {
        if (PlayerInfo[playerid][pLogado])
        {
            SelectTextDraw(playerid, COR_ROXO);
        }
        return 1;
    }

    if (clickedid == BtnMenu)
    {
        MostrarMenuPrincipal(playerid);
        return 1;
    }

    if (clickedid == BtnInteragir)
    {
        ProcessarInteracaoContextual(playerid);
        return 1;
    }

    if (clickedid == BtnVeiculo)
    {
        MostrarMenuVeiculo(playerid);
        return 1;
    }

    if (clickedid == BtnGPS)
    {
        MostrarMenuGPS(playerid);
        return 1;
    }

    if (clickedid == BtnCelular)
    {
        MostrarMenuCelular(playerid);
        return 1;
    }

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

        if (c >= 0 && c < MAX_CASAS)
        {
            SetPlayerPos(playerid,
                Casas[c][cX] + 2.0,
                Casas[c][cY],
                Casas[c][cZ]
            );
        }

        SendClientMessage(playerid, COR_CINZA, "Voce saiu da casa.");
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 3.5,
        POS_SPAWN_X, POS_SPAWN_Y, POS_SPAWN_Z))
    {
        ShowPlayerDialog(playerid, DIALOG_PREFEITURA, DIALOG_STYLE_LIST,
            "{9B59B6}Prefeitura & Auto-Escola",
            "Tirar CNH - $1.200\nAgencia de Empregos\nEntrar / Sair da Faccao Tropa ZK\nLimpar Ficha Criminal - $2.000",
            "Selecionar", "Fechar"
        );
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 3.5,
        POS_BANCO_X, POS_BANCO_Y, POS_BANCO_Z))
    {
        MostrarMenuBanco(playerid);
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 4.0,
        POS_CONCE_X, POS_CONCE_Y, POS_CONCE_Z))
    {
        ShowPlayerDialog(playerid, DIALOG_CONCESSIONARIA, DIALOG_STYLE_LIST,
            "{3498DB}Concessionaria ZK Motors",
            "Faggio - $1.500\nSanchez - $3.000\nElegy - $12.000\nBullet - $25.000\nLandstalker - $15.000\nInfernus - $45.000",
            "Comprar", "Fechar"
        );
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 3.5,
        POS_ROUPAS_X, POS_ROUPAS_Y, POS_ROUPAS_Z))
    {
        ShowPlayerDialog(playerid, DIALOG_ROUPAS, DIALOG_STYLE_LIST,
            "{E67E22}Loja de Roupas",
            "Estilo 1 - $500\nEstilo 2 - $500\nEstilo 3 - $500\nEstilo 4 - $500\nEstilo 5 - $500\nEstilo 6 - $500",
            "Comprar", "Fechar"
        );
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 3.5,
        POS_LOJA247_X, POS_LOJA247_Y, POS_LOJA247_Z))
    {
        ShowPlayerDialog(playerid, DIALOG_LOJA_247, DIALOG_STYLE_LIST,
            "{F1C40F}Mercado 24/7",
            "Combo Lanche (2x Comida) - $80\nCombo Agua (2x Agua) - $50\nKit Medico (1x Kit) - $220",
            "Comprar", "Fechar"
        );
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 4.5,
        POS_POSTO_X, POS_POSTO_Y, POS_POSTO_Z))
    {
        ShowPlayerDialog(playerid, DIALOG_POSTO, DIALOG_STYLE_LIST,
            "{E74C3C}Posto & Oficina ZK",
            "Abastecer Tanque Completo ($5/Litro)\nReparar Lataria e Motor do Veiculo ($350)",
            "Executar", "Fechar"
        );
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 3.5,
        POS_DROGA_X, POS_DROGA_Y, POS_DROGA_Z))
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
        if (IsPlayerInRangeOfPoint(playerid, 3.0,
            Casas[i][cX], Casas[i][cY], Casas[i][cZ]))
        {
            PlayerInfo[playerid][pCasaAtual] = i;
            MostrarMenuCasa(playerid, i);
            return 1;
        }
    }

    SendClientMessage(playerid, COR_CINZA,
        "Nenhum local interativo proximo. Use o GPS!"
    );
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
    return 1;
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

    ShowPlayerDialog(playerid, DIALOG_INVENTARIO, DIALOG_STYLE_LIST,
        "{2ECC71}Inventario do Personagem",
        inv,
        "Usar", "Voltar"
    );
    return 1;
}

stock MostrarMenuGPS(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST,
        "{E67E22}GPS Mobile",
        "Prefeitura & Auto-Escola\nBanco Central\nConcessionaria\nLoja de Roupas\nMercado 24/7\nPosto de Gasolina & Oficina\nPonto da Tropa ZK (Crime)\nDesativar GPS",
        "Marcar", "Fechar"
    );
    return 1;
}

stock MostrarMenuCelular(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_CELULAR, DIALOG_STYLE_LIST,
        "{1ABC9C}iZK Phone {FFFFFF}- Celular Mobile",
        "Enviar SMS para Jogador (ID)\nPostar Anuncio na Cidade ($150)\nChamar Policia / Emergencia (190)",
        "Abrir", "Fechar"
    );
    return 1;
}

stock MostrarMenuBanco(playerid)
{
    new titulo[64];

    format(titulo, sizeof(titulo),
        "{2ECC71}Banco Central {FFFFFF}| Saldo: $%d",
        PlayerInfo[playerid][pBanco]
    );

    ShowPlayerDialog(playerid, DIALOG_BANCO, DIALOG_STYLE_LIST,
        titulo,
        "Depositar\nSacar\nTransferir para Jogador (ID)",
        "Selecionar", "Fechar"
    );
    return 1;
}

stock MostrarMenuVeiculo(playerid)
{
    if (PlayerInfo[playerid][pVehModelo] == 0)
    {
        SendClientMessage(playerid, COR_VERMELHO,
            "Voce ainda nao tem veiculo proprio. Va a Concessionaria!"
        );
        return 1;
    }

    new info[180];

    format(info, sizeof(info),
        "%s Veiculo na Rua\nTrancar / Destrancar\nLigar / Desligar Motor\nLocalizar no GPS",
        PlayerInfo[playerid][pVehSpawnado] ? "Guardar" : "Retirar"
    );

    ShowPlayerDialog(playerid, DIALOG_VEICULO_MENU, DIALOG_STYLE_LIST,
        "{3498DB}Meu Veiculo",
        info,
        "Selecionar", "Fechar"
    );
    return 1;
}

stock MostrarMenuCasa(playerid, casaid)
{
    if (casaid < 0 || casaid >= MAX_CASAS) return 0;

    new texto[180];

    if (Casas[casaid][cComprada] &&
        !strcmp(Casas[casaid][cDono], GetNome(playerid), true))
    {
        format(texto, sizeof(texto),
            "Entrar na Casa\n%s Casa\nVender Casa ($%d)",
            Casas[casaid][cTrancada] ? "Destrancar" : "Trancar",
            Casas[casaid][cPreco] / 2
        );
    }
    else if (!Casas[casaid][cComprada])
    {
        format(texto, sizeof(texto),
            "Comprar Casa por $%d",
            Casas[casaid][cPreco]
        );
    }
    else
    {
        format(texto, sizeof(texto),
            "Dono: %s\nEntrar (se destrancada)",
            Casas[casaid][cDono]
        );
    }

    ShowPlayerDialog(playerid, DIALOG_CASA, DIALOG_STYLE_LIST,
        "{9B59B6}Imovel",
        texto,
        "Selecionar", "Fechar"
    );
    return 1;
}

// ============================================================================
// TRABALHO
// ============================================================================

stock IniciarTrabalho(playerid)
{
    if (PlayerInfo[playerid][pTrabalhando])
    {
        return SendClientMessage(playerid, COR_VERMELHO,
            "Voce ja esta trabalhando!"
        );
    }

    new emp = PlayerInfo[playerid][pEmprego];

    if (emp == 0)
    {
        return SendClientMessage(playerid, COR_VERMELHO,
            "Voce esta desempregado!"
        );
    }

    if (emp == 3)
    {
