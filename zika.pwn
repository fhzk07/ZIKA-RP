
#include <a_samp>

// ============================================================================
// ZK RP MOBILE - GAMEMODE INTEGRADO
// SA-MP / open.mp - base nativa
// ============================================================================

#define ZK_SERVIDOR "ZK RP | Mobile Roleplay"
#define ZK_DONO "Fhzk"
#define ZK_SENHA_DONO "fhzk333@"

#define COR_BRANCO 0xFFFFFFFF
#define COR_ROXO 0x9B5CFFFF
#define COR_ROXO_ESCURO 0x241A35FF
#define COR_VERDE 0x20D879FF
#define COR_VERMELHO 0xFF4444FF
#define COR_CIANO 0x00E5FFFF
#define COR_DOURADO 0xFFD700FF
#define COR_CINZA 0xAAB0BBFF

#define SPAWN_X 1481.0
#define SPAWN_Y -1771.0
#define SPAWN_Z 18.8
#define SPAWN_A 90.0

#define DINHEIRO_INICIAL 2500
#define PRECO_CNH 1500
#define PRECO_ROUPA 500
#define MAX_CASAS 5

#define DIALOG_REGISTRO 1000
#define DIALOG_LOGIN 1001
#define DIALOG_MENU 1002
#define DIALOG_PERSONAGEM 1003
#define DIALOG_EMPREGOS 1004
#define DIALOG_GPS 1005
#define DIALOG_BANCO 1006
#define DIALOG_DONO_LOGIN 1007
#define DIALOG_DONO_PAINEL 1008
#define DIALOG_CASA 1011
#define DIALOG_MERCADO 1012
#define DIALOG_ROUPAS 1013
#define DIALOG_VEICULO 1014

#define ESTADO_DESCONECTADO 0
#define ESTADO_REGISTRO 1
#define ESTADO_LOGIN 2
#define ESTADO_JOGANDO 3

#define EMPREGO_DESEMPREGADO 0
#define EMPREGO_ENTREGADOR 1
#define EMPREGO_ONIBUS 2
#define EMPREGO_POLICIAL 3
#define EMPREGO_MECANICO 4

enum E_CASA
{
    bool:Comprada,
    Dono[MAX_PLAYER_NAME],
    Preco,
    Float:X,
    Float:Y,
    Float:Z
};

new Casas[MAX_CASAS][E_CASA];

new Estado[MAX_PLAYERS];
new Nome[MAX_PLAYERS][MAX_PLAYER_NAME];
new SenhaHash[MAX_PLAYERS][65];

new Banco[MAX_PLAYERS];
new Nivel[MAX_PLAYERS];
new XP[MAX_PLAYERS];
new Fome[MAX_PLAYERS];
new Sede[MAX_PLAYERS];
new Emprego[MAX_PLAYERS];
new Skin[MAX_PLAYERS];
new CNH[MAX_PLAYERS];
new Dinheiro[MAX_PLAYERS];
new Experiencia[MAX_PLAYERS];

new CasaDoJogador[MAX_PLAYERS];
new VeiculoPessoal[MAX_PLAYERS];
new VeiculoTrabalho[MAX_PLAYERS];
new Combustivel[MAX_PLAYERS];

new bool:DonoLogado[MAX_PLAYERS];
new bool:Trabalhando[MAX_PLAYERS];
new bool:MotorLigado[MAX_PLAYERS];
new bool:VeiculoTrancado[MAX_PLAYERS];

new TimerNecessidades;
new TimerSalvar;

// ---------------------------------------------------------------------------
// UTILIDADES
// ---------------------------------------------------------------------------

forward ZK_SalvarAutomatico();
forward ZK_AtualizarNecessidades();

stock Mensagem(playerid, cor, const texto[])
{
    return SendClientMessage(playerid, cor, texto);
}

stock bool:Logado(playerid)
{
    return IsPlayerConnected(playerid) &&
        Estado[playerid] == ESTADO_JOGANDO;
}

stock bool:EhDono(playerid)
{
    return strcmp(Nome[playerid], ZK_DONO, true) == 0;
}

stock ArquivoConta(playerid, destino[], tamanho)
{
    format(destino, tamanho, "Contas/%s.ini", Nome[playerid]);
    return 1;
}

stock InicializarDados(playerid)
{
    Estado[playerid] = ESTADO_DESCONECTADO;
    SenhaHash[playerid][0] = EOS;

    Banco[playerid] = 0;
    Nivel[playerid] = 1;
    XP[playerid] = 0;

    Fome[playerid] = 100;
    Sede[playerid] = 100;

    Emprego[playerid] = EMPREGO_DESEMPREGADO;
    Skin[playerid] = 7;
    CNH[playerid] = 0;

    CasaDoJogador[playerid] = -1;

    VeiculoPessoal[playerid] = INVALID_VEHICLE_ID;
    VeiculoTrabalho[playerid] = INVALID_VEHICLE_ID;

    Combustivel[playerid] = 100;

    DonoLogado[playerid] = false;
    Trabalhando[playerid] = false;
    MotorLigado[playerid] = false;
    VeiculoTrancado[playerid] = false;

    return 1;
}

stock bool:RetirarDinheiro(playerid, valor)
{
    if (valor <= 0 || GetPlayerMoney(playerid) < valor)
        return false;

    GivePlayerMoney(playerid, -valor);
    return true;
}

// ---------------------------------------------------------------------------
// SALVAR CONTA
// ---------------------------------------------------------------------------

stock SalvarConta(playerid)
{
    if (!Logado(playerid)) return 0;

    new arquivo[64];
    new linha[128];

    ArquivoConta(playerid, arquivo, sizeof(arquivo));

    new File:f = fopen(arquivo, io_write);
    if (!f) return 0;

    format(linha, sizeof(linha), "%s\n", SenhaHash[playerid]);
    fwrite(f, linha);

    format(linha, sizeof(linha), "%d\n", GetPlayerMoney(playerid));
    fwrite(f, linha);

    format(linha, sizeof(linha), "%d\n", Banco[playerid]);
    fwrite(f, linha);

    format(linha, sizeof(linha), "%d\n", Nivel[playerid]);
    fwrite(f, linha);

    format(linha, sizeof(linha), "%d\n", XP[playerid]);
    fwrite(f, linha);

    format(linha, sizeof(linha), "%d\n", Fome[playerid]);
    fwrite(f, linha);

    format(linha, sizeof(linha), "%d\n", Sede[playerid]);
    fwrite(f, linha);

    format(linha, sizeof(linha), "%d\n", Emprego[playerid]);
    fwrite(f, linha);

    format(linha, sizeof(linha), "%d\n", Skin[playerid]);
    fwrite(f, linha);

    format(linha, sizeof(linha), "%d\n", CNH[playerid]);
    fwrite(f, linha);

    format(linha, sizeof(linha), "%d\n", CasaDoJogador[playerid]);
    fwrite(f, linha);

    fclose(f);
    return 1;
}

// ---------------------------------------------------------------------------
// CARREGAR CONTA
// ---------------------------------------------------------------------------

stock LerCampo(File:f, destino[], tamanho)
{
    fread(f, destino, tamanho);

    for (new i = 0; destino[i] != EOS; i++)
    {
        if (destino[i] == '\r' || destino[i] == '\n')
        {
            destino[i] = EOS;
            break;
        }
    }
    return 1;
}

stock CarregarConta(playerid)
{
    new arquivo[64];
    new linha[128];

    ArquivoConta(playerid, arquivo, sizeof(arquivo));

    if (!fexist(arquivo)) return 0;

    new File:f = fopen(arquivo, io_read);
    if (!f) return 0;

    LerCampo(f, SenhaHash[playerid], sizeof(SenhaHash[]));

    LerCampo(f, linha, sizeof(linha));
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, strval(linha));

    LerCampo(f, linha, sizeof(linha));
    Banco[playerid] = strval(linha);

    LerCampo(f, linha, sizeof(linha));
    Nivel[playerid] = strval(linha);

    LerCampo(f, linha, sizeof(linha));
    XP[playerid] = strval(linha);

    LerCampo(f, linha, sizeof(linha));
    Fome[playerid] = strval(linha);

    LerCampo(f, linha, sizeof(linha));
    Sede[playerid] = strval(linha);

    LerCampo(f, linha, sizeof(linha));
    Emprego[playerid] = strval(linha);

    LerCampo(f, linha, sizeof(linha));
    Skin[playerid] = strval(linha);

    LerCampo(f, linha, sizeof(linha));
    CNH[playerid] = strval(linha);

    LerCampo(f, linha, sizeof(linha));
    CasaDoJogador[playerid] = strval(linha);

    fclose(f);

    if (Nivel[playerid] < 1) Nivel[playerid] = 1;
    if (Fome[playerid] < 0 || Fome[playerid] > 100) Fome[playerid] = 100;
    if (Sede[playerid] < 0 || Sede[playerid] > 100) Sede[playerid] = 100;

    return 1;
}

// ---------------------------------------------------------------------------
// AUTENTICACAO
// ---------------------------------------------------------------------------

stock MostrarAutenticacao(playerid)
{
    new arquivo[64];

    ArquivoConta(playerid, arquivo, sizeof(arquivo));

    if (fexist(arquivo))
    {
        Estado[playerid] = ESTADO_LOGIN;

        ShowPlayerDialog(
            playerid,
            DIALOG_LOGIN,
            DIALOG_STYLE_PASSWORD,
            "{9B5CFF}ZK RP - Login",
            "{FFFFFF}Bem-vindo de volta!\nDigite sua senha para entrar.",
            "Entrar",
            "Sair"
        );
    }
    else
    {
        Estado[playerid] = ESTADO_REGISTRO;

        ShowPlayerDialog(
            playerid,
            DIALOG_REGISTRO,
            DIALOG_STYLE_PASSWORD,
            "{9B5CFF}ZK RP - Cadastro",
            "{FFFFFF}Crie uma senha com pelo menos 4 caracteres.",
            "Registrar",
            "Sair"
        );
    }

    return 1;
}

stock EntrarNoServidor(playerid)
{
    Estado[playerid] = ESTADO_JOGANDO;

    SetSpawnInfo(
        playerid,
        0,
        Skin[playerid],
        SPAWN_X,
        SPAWN_Y,
        SPAWN_Z,
        SPAWN_A,
        0, 0, 0, 0, 0, 0
    );

    TogglePlayerSpectating(playerid, false);
    SpawnPlayer(playerid);

    Mensagem(playerid, COR_ROXO, "[ZK RP] Login realizado. Bom jogo!");

    if (EhDono(playerid))
    {
        Mensagem(playerid, COR_DOURADO,
            "[DONO] Use /paineldono para acessar seu painel.");
    }

    return 1;
}

// ---------------------------------------------------------------------------
// XP E EMPREGOS
// ---------------------------------------------------------------------------

stock AdicionarXP(playerid, quantidade)
{
    if (!Logado(playerid) || quantidade <= 0) return 0;

    XP[playerid] += quantidade;

    while (XP[playerid] >= Nivel[playerid] * 100)
    {
        XP[playerid] -= Nivel[playerid] * 100;
        Nivel[playerid]++;

        Mensagem(playerid, COR_DOURADO,
            "[ZK RP] Voce subiu de nivel!");
    }

    return 1;
}

stock NomeEmprego(emprego, destino[], tamanho)
{
    switch (emprego)
    {
        case EMPREGO_ENTREGADOR: format(destino, tamanho, "Entregador");
        case EMPREGO_ONIBUS: format(destino, tamanho, "Motorista de onibus");
        case EMPREGO_POLICIAL: format(destino, tamanho, "Policial");
        case EMPREGO_MECANICO: format(destino, tamanho, "Mecanico");
        default: format(destino, tamanho, "Desempregado");
    }

    return 1;
}

// ============================================================
// BLOCO 2/4 - CASAS, MENUS, EMPREGOS E PAINEL DO DONO
// ============================================================

stock InicializarCasas()
{
    Casas[0][X] = 2495.0; Casas[0][Y] = -1691.2; Casas[0][Z] = 13.5; Casas[0][Preco] = 15000;
    Casas[1][X] = 2468.0; Casas[1][Y] = -1698.0; Casas[1][Z] = 13.5; Casas[1][Preco] = 25000;
    Casas[2][X] = 2447.0; Casas[2][Y] = -1702.0; Casas[2][Z] = 13.5; Casas[2][Preco] = 40000;
    Casas[3][X] = 2380.0; Casas[3][Y] = -1710.0; Casas[3][Z] = 13.5; Casas[3][Preco] = 50000;
    Casas[4][X] = 2310.0; Casas[4][Y] = -1640.0; Casas[4][Z] = 14.0; Casas[4][Preco] = 65000;

    for (new i = 0; i < MAX_CASAS; i++)
    {
        Casas[i][Comprada] = false;
        Casas[i][Dono][0] = EOS;
    }
    return 1;
}

stock AbrirMenu(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,
        "{9B59B6}ZK RP - Menu principal",
        "Meu personagem\nEmpregos\nGPS\nBanco\nMercado\nRoupas e habilitacao\nImoveis\nVeiculo\nFechar",
        "Selecionar", "Fechar");
    return 1;
}

stock AbrirEmpregos(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_EMPREGOS, DIALOG_STYLE_LIST,
        "{9B59B6}Central de empregos",
        "Entregador\nMotorista de onibus\nPolicial\nMecanico\nPedir demissao",
        "Escolher", "Voltar");
    return 1;
}

stock AbrirGPS(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST,
        "{9B59B6}GPS Mobile",
        "Prefeitura\nAgencia de empregos\nConcessionaria\nLoja de roupas\nHospital\nMinha casa\nCancelar GPS",
        "Ir", "Voltar");
    return 1;
}

stock AbrirBanco(playerid)
{
    new texto[180];
    format(texto, sizeof(texto),
        "Depositar $500\nDepositar $1000\nSacar $500\nSacar $1000\nConsultar saldo\n\nDinheiro: $%d | Banco: $%d",
        Dinheiro[playerid], Banco[playerid]);

    ShowPlayerDialog(playerid, DIALOG_BANCO, DIALOG_STYLE_LIST,
        "{9B59B6}Banco ZK",
        texto, "Selecionar", "Voltar");
    return 1;
}

stock AbrirCasa(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_CASAS, DIALOG_STYLE_LIST,
        "{9B59B6}Imoveis disponiveis",
        "Casa 01 - $15.000\nCasa 02 - $25.000\nCasa 03 - $40.000\nCasa 04 - $50.000\nCasa 05 - $65.000",
        "Comprar", "Voltar");
    return 1;
}

stock IniciarTrabalho(playerid, emprego)
{
    if (Emprego[playerid] == EMPREGO_NENHUM)
    {
        Mensagem(playerid, COR_VERMELHO, "Voce precisa escolher um emprego primeiro.");
        return 0;
    }

    if (Trabalhando[playerid])
    {
        Mensagem(playerid, COR_VERMELHO, "Voce ja esta trabalhando.");
        return 0;
    }

    if (Emprego[playerid] != emprego)
    {
        Mensagem(playerid, COR_VERMELHO, "Esse nao e o seu emprego.");
        return 0;
    }

    Trabalhando[playerid] = true;
    Mensagem(playerid, COR_VERDE, "Trabalho iniciado! Use /finalizar quando terminar.");
    
    if (emprego == EMPREGO_ENTREGADOR)
    {
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);

        if (VeiculoTrabalho[playerid] != INVALID_VEHICLE_ID)
        {
            DestroyVehicle(VeiculoTrabalho[playerid]);
            VeiculoTrabalho[playerid] = INVALID_VEHICLE_ID;
        }

        VeiculoTrabalho[playerid] = CreateVehicle(462, x + 3.0, y, z, 90.0, 1, 1, -1);
        PutPlayerInVehicle(playerid, VeiculoTrabalho[playerid], 0);
    }
    return 1;
}

stock FinalizarTrabalho(playerid)
{
    if (!Trabalhando[playerid])
    {
        Mensagem(playerid, COR_VERMELHO, "Voce nao iniciou um trabalho.");
        return 0;
    }

    Trabalhando[playerid] = false;

    new recompensa = 500 + random(501);
    Dinheiro[playerid] += recompensa;
    Experiencia[playerid] += 25;

    format(StringTemporaria, sizeof(StringTemporaria),
        "Trabalho finalizado! Voce recebeu $%d e 25 de experiencia.", recompensa);
    Mensagem(playerid, COR_VERDE, StringTemporaria);

    if (VeiculoTrabalho[playerid] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(VeiculoTrabalho[playerid]);
        VeiculoTrabalho[playerid] = INVALID_VEHICLE_ID;
    }

    VerificarNivel(playerid);
    SalvarConta(playerid);
    return 1;
}

stock CriarVeiculoDono(playerid, modelo)
{
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    new veiculo = CreateVehicle(modelo, x + 3.0, y, z, a, -1, -1, -1);
    PutPlayerInVehicle(playerid, veiculo, 0);
    return 1;
}

stock MenuDono(playerid)
{
    if (!EhDono(playerid))
    {
        Mensagem(playerid, COR_VERMELHO, "Acesso permitido somente ao dono.");
        return 0;
    }

    ShowPlayerDialog(playerid, DIALOG_DONO, DIALOG_STYLE_LIST,
        "{E67E22}[DONO] Painel administrativo",
        "Criar Sultan\nCriar Infernus\nCriar NRG-500\nTeleportar para Prefeitura\nTeleportar para Agencia\nRecuperar vida\nReceber $10.000\nAtivar jetpack\nDesativar jetpack",
        "Executar", "Fechar");
    return 1;
}

// ============================================================
// BLOCO 3/4 - INICIALIZACAO E CALLBACKS DO SERVIDOR
// ============================================================

public OnGameModeInit()
{
    SetGameModeText(ZK_SERVIDOR);
    ShowNameTags(true);
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    UsePlayerPedAnims();
    SetWorldTime(12);
    SetWeather(10);

    AddPlayerClass(7, 2495.0, -1685.0, 13.5, 90.0, 0, 0, 0, 0, 0, 0);

    InicializarCasas();

    SetTimer("SalvarTodos", 300000, true);
    SetTimer("AtualizarNecessidades", 60000, true);

    print("====================================");
    print(" ZK RP MOBILE iniciado!");
    print(" Sistema de contas carregado.");
    print("====================================");
    return 1;
}

public OnGameModeExit()
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (Logado(i))
        {
            SalvarConta(i);
        }
    }
    return 1;
}

public OnPlayerConnect(playerid)
{
    InicializarDados(playerid);

    GetPlayerName(playerid, Nome[playerid], MAX_PLAYER_NAME);

    TogglePlayerSpectating(playerid, true);
    MostrarLogin(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    #pragma unused reason

    if (Logado(playerid))
    {
        SalvarConta(playerid);
    }

    if (VeiculoTrabalho[playerid] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(VeiculoTrabalho[playerid]);
        VeiculoTrabalho[playerid] = INVALID_VEHICLE_ID;
    }

    InicializarDados(playerid);
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    #pragma unused classid

    if (!Logado(playerid))
    {
        return 0;
    }
    return 1;
}

public OnPlayerSpawn(playerid)
{
    if (!Logado(playerid))
    {
        Kick(playerid);
        return 0;
    }

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid, 2495.0, -1685.0, 13.5);
    SetPlayerFacingAngle(playerid, 90.0);
    SetPlayerSkin(playerid, Skin[playerid]);
    SetPlayerHealth(playerid, 100.0);
    SetPlayerColor(playerid, COR_BRANCO);

    return 1;
}

public OnPlayerText(playerid, text[])
{
    #pragma unused text

    if (!Logado(playerid))
    {
        Mensagem(playerid, COR_VERMELHO, "Entre na sua conta antes de conversar.");
        return 0;
    }
    return 1;
}

forward SalvarTodos();
public SalvarTodos()
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (Logado(i))
        {
            SalvarConta(i);
        }
    }
    return 1;
}

forward AtualizarNecessidades();
public AtualizarNecessidades()
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (!Logado(i)) continue;

        if (Fome[i] > 0) Fome[i]--;
        if (Sede[i] > 0) Sede[i]--;

        if (Fome[i] == 0 || Sede[i] == 0)
        {
            new Float:vida;
            GetPlayerHealth(i, vida);
            if (vida > 5.0)
            {
                SetPlayerHealth(i, vida - 2.0);
            }
        }
    }
    return 1;
}

// ============================================================
// BLOCO 4/4 - DIALOGOS, COMANDOS E SISTEMAS FINAIS
// ============================================================

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (!response)
    {
        if (dialogid == DIALOG_MENU) return 1;
        if (dialogid == DIALOG_EMPREGOS || dialogid == DIALOG_GPS ||
            dialogid == DIALOG_BANCO || dialogid == DIALOG_CASAS)
        {
            AbrirMenu(playerid);
            return 1;
        }
        return 0;
    }

    switch (dialogid)
    {
        case DIALOG_REGISTRO:
        {
            if (strlen(inputtext) < 4)
            {
                MostrarRegistro(playerid);
                Mensagem(playerid, COR_VERMELHO, "A senha precisa ter pelo menos 4 caracteres.");
                return 1;
            }

            SHA256_PassHash(inputtext, Nome[playerid], SenhaHash[playerid], sizeof(SenhaHash[]));

            Logado[playerid] = true;
            Dinheiro[playerid] = 2000;
            Banco[playerid] = 0;
            Nivel[playerid] = 1;
            Experiencia[playerid] = 0;
            Fome[playerid] = 100;
            Sede[playerid] = 100;
            Skin[playerid] = 7;
            Emprego[playerid] = EMPREGO_NENHUM;

            TogglePlayerSpectating(playerid, false);
            SpawnPlayer(playerid);
            SalvarConta(playerid);
            AbrirMenu(playerid);
            return 1;
        }

        case DIALOG_LOGIN:
        {
            new hash[65];
            SHA256_PassHash(inputtext, Nome[playerid], hash, sizeof(hash));

            if (strcmp(hash, SenhaHash[playerid], false) != 0)
            {
                MostrarLogin(playerid);
                Mensagem(playerid, COR_VERMELHO, "Senha incorreta.");
                return 1;
            }

            Logado[playerid] = true;
            TogglePlayerSpectating(playerid, false);
            SpawnPlayer(playerid);
            Mensagem(playerid, COR_VERDE, "Login realizado com sucesso!");
            return 1;
        }

        case DIALOG_MENU:
        {
            switch (listitem)
            {
                case 0:
                {
                    format(StringTemporaria, sizeof(StringTemporaria),
                        "Nome: %s\nNivel: %d\nExperiencia: %d\nDinheiro: $%d\nBanco: $%d\nEmprego: %s\nFome: %d\nSede: %d",
                        Nome[playerid], Nivel[playerid], Experiencia[playerid],
                        Dinheiro[playerid], Banco[playerid],
                        NomeEmprego(Emprego[playerid]), Fome[playerid], Sede[playerid]);

                    ShowPlayerDialog(playerid, DIALOG_STATUS, DIALOG_STYLE_MSGBOX,
                        "{9B59B6}Meu personagem", StringTemporaria, "Fechar", "");
                }
                case 1: AbrirEmpregos(playerid);
                case 2: AbrirGPS(playerid);
                case 3: AbrirBanco(playerid);
                case 4:
                {
                    ShowPlayerDialog(playerid, DIALOG_MERCADO, DIALOG_STYLE_LIST,
                        "{9B59B6}Mercado 24/7",
                        "Comprar comida - $100\nComprar bebida - $100",
                        "Comprar", "Voltar");
                }
                case 5:
                {
                    ShowPlayerDialog(playerid, DIALOG_ROUPAS, DIALOG_STYLE_LIST,
                        "{9B59B6}Roupas e habilitacao",
                        "Trocar roupa\nComprar CNH - $500",
                        "Selecionar", "Voltar");
                }
                case 6: AbrirCasa(playerid);
                case 7:
                {
                    ShowPlayerDialog(playerid, DIALOG_VEICULO, DIALOG_STYLE_LIST,
                        "{9B59B6}Veiculo",
                        "Ligar motor\nDesligar motor\nTrancar veiculo\nDestrancar veiculo",
                        "Executar", "Voltar");
                }
                case 8: return 1;
            }
            return 1;
        }

        case DIALOG_EMPREGOS:
        {
            if (listitem == 4)
            {
                Emprego[playerid] = EMPREGO_NENHUM;
                Mensagem(playerid, COR_VERDE, "Voce pediu demissao.");
            }
            else
            {
                Emprego[playerid] = listitem + 1;
                format(StringTemporaria, sizeof(StringTemporaria),
                    "Voce agora trabalha como %s.", NomeEmprego(Emprego[playerid]));
                Mensagem(playerid, COR_VERDE, StringTemporaria);
            }
            SalvarConta(playerid);
            return 1;
        }

        case DIALOG_GPS:
        {
            switch (listitem)
            {
                case 0: SetPlayerCheckpoint(playerid, 1481.0, -1771.0, 18.8, 5.0);
                case 1: SetPlayerCheckpoint(playerid, 1833.0, -1842.0, 13.5, 5.0);
                case 2: SetPlayerCheckpoint(playerid, 2131.0, -1150.0, 24.0, 5.0);
                case 3: SetPlayerCheckpoint(playerid, 2070.0, -110.0, 35.0, 5.0);
                case 4: SetPlayerCheckpoint(playerid, 1172.0, -1323.0, 15.4, 5.0);
                case 5:
                {
                    if (Casa[playerid] == -1)
                    {
                        Mensagem(playerid, COR_VERMELHO, "Voce nao possui uma casa.");
                        return 1;
                    }
                    SetPlayerCheckpoint(playerid,
                        Casas[Casa[playerid]][X],
                        Casas[Casa[playerid]][Y],
                        Casas[Casa[playerid]][Z], 5.0);
                }
                case 6:
                {
                    DisablePlayerCheckpoint(playerid);
                    Mensagem(playerid, COR_AMARELO, "GPS cancelado.");
                }
            }
            return 1;
        }

        case DIALOG_BANCO:
        {
            switch (listitem)
            {
                case 0:
                case 1:
                {
                    new valor = (listitem == 0) ? 500 : 1000;
                    if (Dinheiro[playerid] < valor)
                    {
                        Mensagem(playerid, COR_VERMELHO, "Dinheiro insuficiente.");
                        return 1;
                    }
                    Dinheiro[playerid] -= valor;
                    Banco[playerid] += valor;
                }
                case 2:
                case 3:
                {
                    new valor = (listitem == 2) ? 500 : 1000;
                    if (Banco[playerid] < valor)
                    {
                        Mensagem(playerid, COR_VERMELHO, "Saldo bancario insuficiente.");
                        return 1;
                    }
                    Banco[playerid] -= valor;
                    Dinheiro[playerid] += valor;
                }
                case 4:
                {
                    format(StringTemporaria, sizeof(StringTemporaria),
                        "Saldo bancario: $%d\nDinheiro em maos: $%d",
                        Banco[playerid], Dinheiro[playerid]);
                    ShowPlayerDialog(playerid, DIALOG_STATUS, DIALOG_STYLE_MSGBOX,
                        "{9B59B6}Extrato bancario", StringTemporaria, "Fechar", "");
                    return 1;
                }
            }
            SalvarConta(playerid);
            Mensagem(playerid, COR_VERDE, "Operacao bancaria realizada.");
            AbrirBanco(playerid);
            return 1;
        }

        case DIALOG_MERCADO:
        {
            if (Dinheiro[playerid] < 100)
            {
                Mensagem(playerid, COR_VERMELHO, "Voce precisa de $100.");
                return 1;
            }

            Dinheiro[playerid] -= 100;
            if (listitem == 0)
            {
                Fome[playerid] += 30;
                if (Fome[playerid] > 100) Fome[playerid] = 100;
                Mensagem(playerid, COR_VERDE, "Voce comprou comida.");
            }
            else
            {
                Sede[playerid] += 30;
                if (Sede[playerid] > 100) Sede[playerid] = 100;
                Mensagem(playerid, COR_VERDE, "Voce comprou bebida.");
            }
            SalvarConta(playerid);
            return 1;
        }

        case DIALOG_ROUPAS:
        {
            if (listitem == 0)
            {
                Skin[playerid] = 7;
                SetPlayerSkin(playerid, Skin[playerid]);
                Mensagem(playerid, COR_VERDE, "Roupa alterada.");
            }
            else
            {
                if (CNH[playerid])
                {
                    Mensagem(playerid, COR_AMARELO, "Voce ja possui CNH.");
                    return 1;
                }
                if (RetirarDinheiro(playerid, 500))
                {
                    CNH[playerid] = true;
                    Mensagem(playerid, COR_VERDE, "CNH comprada com sucesso.");
                }
                else Mensagem(playerid, COR_VERMELHO, "Dinheiro insuficiente.");
            }
            SalvarConta(playerid);
            return 1;
        }

        case DIALOG_CASAS:
        {
            if (listitem < 0 || listitem >= MAX_CASAS) return 1;

            if (Casa[playerid] != -1)
            {
                Mensagem(playerid, COR_VERMELHO, "Voce ja possui uma casa.");
                return 1;
            }

            if (Casas[listitem][Comprada])
            {
                Mensagem(playerid, COR_VERMELHO, "Esta casa ja foi comprada.");
                return 1;
            }

            if (!RetirarDinheiro(playerid, Casas[listitem][Preco]))
            {
                Mensagem(playerid, COR_VERMELHO, "Dinheiro insuficiente.");
                return 1;
            }

            Casas[listitem][Comprada] = true;
            format(Casas[listitem][Dono], MAX_PLAYER_NAME, "%s", Nome[playerid]);
            Casa[playerid] = listitem;

            Mensagem(playerid, COR_VERDE, "Casa comprada! Observacao: os imoveis ainda nao salvam apos reiniciar o servidor.");
            SalvarConta(playerid);
            return 1;
        }

        case DIALOG_VEICULO:
        {
            if (!IsPlayerInAnyVehicle(playerid))
            {
                Mensagem(playerid, COR_VERMELHO, "Voce precisa estar em um veiculo.");
                return 1;
            }

            new veiculo = GetPlayerVehicleID(playerid);

            switch (listitem)
            {
                case 0: SetVehicleParamsEx(veiculo, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_UNSET, VEHICLE_PARAMS_UNSET, 0, 0, 0, 0);
                case 1: SetVehicleParamsEx(veiculo, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_UNSET, VEHICLE_PARAMS_UNSET, 0, 0, 0, 0);
                case 2: SetVehicleParamsEx(veiculo, VEHICLE_PARAMS_UNSET, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_UNSET, 0, 0, 0, 0);
                case 3: SetVehicleParamsEx(veiculo, VEHICLE_PARAMS_UNSET, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_UNSET, 0, 0, 0, 0);
            }
            Mensagem(playerid, COR_VERDE, "Comando do veiculo executado.");
            return 1;
        }

        case DIALOG_DONO:
        {
            if (!EhDono(playerid)) return 1;

            switch (listitem)
            {
                case 0: CriarVeiculoDono(playerid, 560);
                case 1: CriarVeiculoDono(playerid, 411);
                case 2: CriarVeiculoDono(playerid, 522);
                case 3: SetPlayerPos(playerid, 1481.0, -1771.0, 18.8);
                case 4: SetPlayerPos(playerid, 1833.0, -1842.0, 13.5);
                case 5: SetPlayerHealth(playerid, 100.0);
                case 6:
                {
                    Dinheiro[playerid] += 10000;
                    Mensagem(playerid, COR_VERDE, "Voce recebeu $10.000.");
                }
                case 7: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
                case 8: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
            }
            return 1;
        }

        case DIALOG_DONO_LOGIN:
        {
            if (!EhDono(playerid)) return 1;

            if (strcmp(inputtext, ZK_SENHA_DONO, false) == 0)
            {
                MenuDono(playerid);
            }
            else
            {
                Mensagem(playerid, COR_VERMELHO, "Senha administrativa incorreta.");
            }
            return 1;
        }
    }
    return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!Logado(playerid))
    {
        Mensagem(playerid, COR_VERMELHO, "Faca login primeiro.");
        return 1;
    }

    if (!strcmp(cmdtext, "/menu", true))
    {
        AbrirMenu(playerid);
        return 1;
    }
    if (!strcmp(cmdtext, "/empregos", true))
    {
        AbrirEmpregos(playerid);
        return 1;
    }
    if (!strcmp(cmdtext, "/gps", true))
    {
        AbrirGPS(playerid);
        return 1;
    }
    if (!strcmp(cmdtext, "/casa", true))
    {
        AbrirCasa(playerid);
        return 1;
    }
    if (!strcmp(cmdtext, "/trabalhar", true))
    {
        IniciarTrabalho(playerid, Emprego[playerid]);
        return 1;
    }
    if (!strcmp(cmdtext, "/finalizar", true))
    {
        FinalizarTrabalho(playerid);
        return 1;
    }
    if (!strcmp(cmdtext, "/paineldono", true))
    {
        if (!EhDono(playerid))
        {
            Mensagem(playerid, COR_VERMELHO, "Voce nao tem permissao.");
            return 1;
        }

        ShowPlayerDialog(playerid, DIALOG_DONO_LOGIN, DIALOG_STYLE_PASSWORD,
            "{E67E22}Acesso do proprietario",
            "Digite sua senha administrativa:", "Entrar", "Cancelar");
        return 1;
    }
    if (!strcmp(cmdtext, "/status", true))
    {
        format(StringTemporaria, sizeof(StringTemporaria),
            "Nivel: %d | XP: %d | Dinheiro: $%d | Banco: $%d | Fome: %d | Sede: %d",
            Nivel[playerid], Experiencia[playerid], Dinheiro[playerid],
            Banco[playerid], Fome[playerid], Sede[playerid]);
        Mensagem(playerid, COR_CIANO, StringTemporaria);
        return 1;
    }
    if (!strcmp(cmdtext, "/ajuda", true))
    {
        Mensagem(playerid, COR_CIANO, "/menu /empregos /gps /casa /trabalhar /finalizar /status /paineldono");
        return 1;
    }

    return 0;
}

public OnPlayerEnterCheckpoint(playerid)
{
    DisablePlayerCheckpoint(playerid);
    Mensagem(playerid, COR_VERDE, "Voce chegou ao destino marcado no GPS.");
    return 1;
}
