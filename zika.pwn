
#include <a_samp>

// ============================================================
// ZK RP MOBILE - GAMEMODE RECONSTRUIDO
// ============================================================

#define ZK_SERVIDOR "ZK RP | Mobile Roleplay"
#define ZK_DONO "Fhzk"
#define ZK_SENHA_DONO "fhzk333@"

#define COR_BRANCO 0xFFFFFFFF
#define COR_ROXO 0x9B5CFFFF
#define COR_VERDE 0x20D879FF
#define COR_VERMELHO 0xFF4444FF
#define COR_CIANO 0x00E5FFFF
#define COR_DOURADO 0xFFD700FF

#define MAX_CASAS 5

#define DINHEIRO_INICIAL 2500

#define DIALOG_REGISTRO 1000
#define DIALOG_LOGIN 1001
#define DIALOG_MENU 1002
#define DIALOG_EMPREGOS 1003
#define DIALOG_GPS 1004
#define DIALOG_BANCO 1005
#define DIALOG_CASAS 1006
#define DIALOG_MERCADO 1007
#define DIALOG_ROUPAS 1008
#define DIALOG_VEICULO 1009
#define DIALOG_DONO_LOGIN 1010
#define DIALOG_DONO 1011
#define DIALOG_STATUS 1012

#define EMPREGO_NENHUM 0
#define EMPREGO_ENTREGADOR 1
#define EMPREGO_ONIBUS 2
#define EMPREGO_POLICIAL 3
#define EMPREGO_MECANICO 4

enum E_PLAYER
{
    bool:Logado,
    SenhaHash[65],
    Dinheiro,
    Banco,
    Nivel,
    Experiencia,
    Fome,
    Sede,
    Emprego,
    Skin,
    bool:CNH,
    Casa,
    bool:Trabalhando,
    VeiculoTrabalho
};

new Dados[MAX_PLAYERS][E_PLAYER];

enum E_CASA
{
    Float:CasaX,
    Float:CasaY,
    Float:CasaZ,
    Preco,
    bool:Comprada,
    Dono[MAX_PLAYER_NAME]
};

new Casas[MAX_CASAS][E_CASA];

new Nome[MAX_PLAYERS][MAX_PLAYER_NAME];
new StringTemporaria[256];

// ============================================================
// FUNCOES BASICAS
// ============================================================

stock Mensagem(playerid, cor, const texto[])
{
    SendClientMessage(playerid, cor, texto);
    return 1;
}

stock bool:EhDono(playerid)
{
    GetPlayerName(playerid, Nome[playerid], MAX_PLAYER_NAME);

    if (strcmp(Nome[playerid], ZK_DONO, true) == 0)
        return true;

    return false;
}

stock InicializarDados(playerid)
{
    Dados[playerid][Logado] = false;
    Dados[playerid][Dinheiro] = DINHEIRO_INICIAL;
    Dados[playerid][Banco] = 0;
    Dados[playerid][Nivel] = 1;
    Dados[playerid][Experiencia] = 0;
    Dados[playerid][Fome] = 100;
    Dados[playerid][Sede] = 100;
    Dados[playerid][Emprego] = EMPREGO_NENHUM;
    Dados[playerid][Skin] = 7;
    Dados[playerid][CNH] = false;
    Dados[playerid][Casa] = -1;
    Dados[playerid][Trabalhando] = false;
    Dados[playerid][VeiculoTrabalho] = INVALID_VEHICLE_ID;
    Dados[playerid][SenhaHash][0] = EOS;
    return 1;
}

stock RetirarDinheiro(playerid, valor)
{
    if (Dados[playerid][Dinheiro] < valor)
        return 0;

    Dados[playerid][Dinheiro] -= valor;
    return 1;
}

stock NomeEmprego(emprego)
{
    switch (emprego)
    {
        case EMPREGO_ENTREGADOR: return "Entregador";
        case EMPREGO_ONIBUS: return "Motorista de onibus";
        case EMPREGO_POLICIAL: return "Policial";
        case EMPREGO_MECANICO: return "Mecanico";
    }
    return "Desempregado";
}

// ============================================================
// SISTEMA DE CONTAS
// ============================================================

stock ArquivoConta(playerid, destino[], tamanho)
{
    format(destino, tamanho, "Contas/%s.ini", Nome[playerid]);
    return 1;
}

stock SalvarConta(playerid)
{
    if (!Dados[playerid][Logado])
        return 0;

    new arquivo[64];
    ArquivoConta(playerid, arquivo, sizeof(arquivo));

    new File:conta = fopen(arquivo, io_write);

    if (!conta)
        return 0;

    format(StringTemporaria, sizeof(StringTemporaria), "%s\n", Dados[playerid][SenhaHash]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Dinheiro]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Banco]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Nivel]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Experiencia]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Fome]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Sede]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Emprego]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Skin]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][CNH]);
    fwrite(conta, StringTemporaria);

    format(StringTemporaria, sizeof(StringTemporaria), "%d\n", Dados[playerid][Casa]);
    fwrite(conta, StringTemporaria);

    fclose(conta);
    return 1;
}

// ============================================================
// PARTE 2/4 - CARREGAMENTO, LOGIN E MENUS
// ============================================================

stock CarregarConta(playerid)
{
    new arquivo[64];
    ArquivoConta(playerid, arquivo, sizeof(arquivo));

    if (!fexist(arquivo))
        return 0;

    new File:conta = fopen(arquivo, io_read);
    if (!conta)
        return 0;

    new linha[128];

    fread(conta, linha);
    format(Dados[playerid][SenhaHash], 65, "%s", linha);

    fread(conta, linha);
    Dados[playerid][Dinheiro] = strval(linha);

    fread(conta, linha);
    Dados[playerid][Banco] = strval(linha);

    fread(conta, linha);
    Dados[playerid][Nivel] = strval(linha);

    fread(conta, linha);
    Dados[playerid][Experiencia] = strval(linha);

    fread(conta, linha);
    Dados[playerid][Fome] = strval(linha);

    fread(conta, linha);
    Dados[playerid][Sede] = strval(linha);

    fread(conta, linha);
    Dados[playerid][Emprego] = strval(linha);

    fread(conta, linha);
    Dados[playerid][Skin] = strval(linha);

    fread(conta, linha);
    Dados[playerid][CNH] = strval(linha);

    fread(conta, linha);
    Dados[playerid][Casa] = strval(linha);

    fclose(conta);
    return 1;
}

stock MostrarRegistro(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_REGISTRO,
        DIALOG_STYLE_PASSWORD,
        "{9B5CFF}ZK RP - Registro",
        "Bem-vindo ao ZK RP!\n\nCrie uma senha para sua conta:",
        "Registrar", "Sair");
    return 1;
}

stock MostrarLogin(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_LOGIN,
        DIALOG_STYLE_PASSWORD,
        "{9B5CFF}ZK RP - Login",
        "Digite sua senha para entrar no servidor:",
        "Entrar", "Sair");
    return 1;
}

stock AbrirMenu(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_MENU,
        DIALOG_STYLE_LIST,
        "{9B5CFF}ZK RP - Menu principal",
        "Meu personagem\nEmpregos\nGPS\nBanco\nMercado\nRoupas e CNH\nImoveis\nVeiculo",
        "Selecionar", "Fechar");
    return 1;
}

stock AbrirEmpregos(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_EMPREGOS,
        DIALOG_STYLE_LIST,
        "{9B5CFF}Central de empregos",
        "Entregador\nMotorista de onibus\nPolicial\nMecanico\nPedir demissao",
        "Selecionar", "Voltar");
    return 1;
}

stock AbrirGPS(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_GPS,
        DIALOG_STYLE_LIST,
        "{9B5CFF}GPS Mobile",
        "Prefeitura\nAgencia de empregos\nConcessionaria\nLoja de roupas\nHospital\nMinha casa\nCancelar GPS",
        "Marcar", "Voltar");
    return 1;
}

stock AbrirBanco(playerid)
{
    format(StringTemporaria, sizeof(StringTemporaria),
        "Depositar $500\nDepositar $1000\nSacar $500\nSacar $1000\nConsultar saldo\n\nDinheiro: $%d | Banco: $%d",
        Dados[playerid][Dinheiro],
        Dados[playerid][Banco]);

    ShowPlayerDialog(playerid, DIALOG_BANCO,
        DIALOG_STYLE_LIST,
        "{9B5CFF}Banco ZK",
        StringTemporaria,
        "Selecionar", "Voltar");
    return 1;
}

stock AbrirCasas(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_CASAS,
        DIALOG_STYLE_LIST,
        "{9B5CFF}Imoveis disponiveis",
        "Casa 01 - $15.000\nCasa 02 - $25.000\nCasa 03 - $40.000\nCasa 04 - $50.000\nCasa 05 - $65.000",
        "Comprar", "Voltar");
    return 1;
}

// ============================================================
// SISTEMA DE CASAS
// ============================================================

stock InicializarCasas()
{
    Casas[0][CasaX] = 2495.0;
    Casas[0][CasaY] = -1691.2;
    Casas[0][CasaZ] = 13.5;
    Casas[0][Preco] = 15000;

    Casas[1][CasaX] = 2468.0;
    Casas[1][CasaY] = -1698.0;
    Casas[1][CasaZ] = 13.5;
    Casas[1][Preco] = 25000;

    Casas[2][CasaX] = 2447.0;
    Casas[2][CasaY] = -1702.0;
    Casas[2][CasaZ] = 13.5;
    Casas[2][Preco] = 40000;

    Casas[3][CasaX] = 2380.0;
    Casas[3][CasaY] = -1710.0;
    Casas[3][CasaZ] = 13.5;
    Casas[3][Preco] = 50000;

    Casas[4][CasaX] = 2310.0;
    Casas[4][CasaY] = -1640.0;
    Casas[4][CasaZ] = 14.0;
    Casas[4][Preco] = 65000;

    for (new i = 0; i < MAX_CASAS; i++)
    {
        Casas[i][Comprada] = false;
        Casas[i][Dono][0] = EOS;
    }
    return 1;
}

// ============================================================
// SISTEMA DE EXPERIENCIA
// ============================================================

stock VerificarNivel(playerid)
{
    while (Dados[playerid][Experiencia] >= Dados[playerid][Nivel] * 100)
    {
        Dados[playerid][Experiencia] -= Dados[playerid][Nivel] * 100;
        Dados[playerid][Nivel]++;

        format(StringTemporaria, sizeof(StringTemporaria),
            "Parabens! Voce alcancou o nivel %d.",
            Dados[playerid][Nivel]);

        Mensagem(playerid, COR_DOURADO, StringTemporaria);
    }
    return 1;
}

// ============================================================
// SISTEMA DE TRABALHO
// ============================================================

stock IniciarTrabalho(playerid)
{
    if (Dados[playerid][Emprego] == EMPREGO_NENHUM)
    {
        Mensagem(playerid, COR_VERMELHO,
            "Voce precisa escolher um emprego primeiro.");
        return 0;
    }

    if (Dados[playerid][Trabalhando])
    {
        Mensagem(playerid, COR_VERMELHO,
            "Voce ja esta trabalhando.");
        return 0;
    }

    Dados[playerid][Trabalhando] = true;

    Mensagem(playerid, COR_VERDE,
        "Trabalho iniciado! Use /finalizar para receber.");

    if (Dados[playerid][Emprego] == EMPREGO_ENTREGADOR)
    {
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);

        Dados[playerid][VeiculoTrabalho] =
            CreateVehicle(462, x + 3.0, y, z, 90.0, 1, 1, -1);

        if (Dados[playerid][VeiculoTrabalho] != INVALID_VEHICLE_ID)
        {
            PutPlayerInVehicle(playerid,
                Dados[playerid][VeiculoTrabalho], 0);
        }
    }
    return 1;
}

stock FinalizarTrabalho(playerid)
{
    if (!Dados[playerid][Trabalhando])
    {
        Mensagem(playerid, COR_VERMELHO,
            "Voce nao iniciou um trabalho.");
        return 0;
    }

    Dados[playerid][Trabalhando] = false;

    new recompensa = 500 + random(501);

    Dados[playerid][Dinheiro] += recompensa;
    Dados[playerid][Experiencia] += 25;

    format(StringTemporaria, sizeof(StringTemporaria),
        "Trabalho finalizado! Voce recebeu $%d.",
        recompensa);

    Mensagem(playerid, COR_VERDE, StringTemporaria);

    if (Dados[playerid][VeiculoTrabalho] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(Dados[playerid][VeiculoTrabalho]);
        Dados[playerid][VeiculoTrabalho] = INVALID_VEHICLE_ID;
    }

    VerificarNivel(playerid);
    SalvarConta(playerid);
    return 1;
}

// ============================================================
// PAINEL DO DONO
// ============================================================

stock AbrirPainelDono(playerid)
{
    if (!EhDono(playerid))
    {
        Mensagem(playerid, COR_VERMELHO,
            "Somente o dono pode acessar este painel.");
        return 0;
    }

    ShowPlayerDialog(playerid, DIALOG_DONO,
        DIALOG_STYLE_LIST,
        "{FFD700}[DONO] Painel administrativo",
        "Criar Sultan\nCriar Infernus\nCriar NRG-500\nIr para Prefeitura\nIr para Agencia\nRecuperar vida\nReceber $10.000\nAtivar jetpack\nDesativar jetpack",
        "Executar", "Fechar");
    return 1;
}

stock CriarVeiculoDono(playerid, modelo)
{
    new Float:x, Float:y, Float:z, Float:a;

    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    new veiculo = CreateVehicle(modelo,
        x + 3.0, y, z, a, -1, -1, -1);

    if (veiculo != INVALID_VEHICLE_ID)
        PutPlayerInVehicle(playerid, veiculo, 0);

    return 1;
}

// ============================================================
// PARTE 3/4 - COMANDOS E SISTEMAS DO JOGADOR
// ============================================================

stock EntrarNoServidor(playerid)
{
    Dados[playerid][Logado] = true;

    SetPlayerScore(playerid, Dados[playerid][Nivel]);
    GivePlayerMoney(playerid, Dados[playerid][Dinheiro]);
    SetPlayerSkin(playerid, Dados[playerid][Skin]);

    SetSpawnInfo(playerid, 0, Dados[playerid][Skin],
        1481.0, -1771.0, 18.8, 90.0,
        0, 0, 0, 0, 0, 0);

    SpawnPlayer(playerid);

    Mensagem(playerid, COR_VERDE,
        "Bem-vindo ao ZK RP Mobile!");

    if (EhDono(playerid))
    {
        Mensagem(playerid, COR_DOURADO,
            "[DONO] Voce entrou no servidor.");
    }

    return 1;
}

stock AtualizarNecessidades(playerid)
{
    if (!Dados[playerid][Logado])
        return 0;

    if (Dados[playerid][Fome] > 0)
        Dados[playerid][Fome]--;

    if (Dados[playerid][Sede] > 0)
        Dados[playerid][Sede]--;

    if (Dados[playerid][Fome] <= 0 ||
        Dados[playerid][Sede] <= 0)
    {
        new Float:vida;
        GetPlayerHealth(playerid, vida);

        vida -= 5.0;

        if (vida <= 0.0)
            SetPlayerHealth(playerid, 10.0);
        else
            SetPlayerHealth(playerid, vida);
    }

    return 1;
}

stock SalvarTodos()
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (Dados[i][Logado])
            SalvarConta(i);
    }
    return 1;
}

stock MostrarStatus(playerid)
{
    format(StringTemporaria, sizeof(StringTemporaria),
        "{FFFFFF}Personagem: %s\n\
{FFFFFF}Nivel: %d\n\
{FFFFFF}Experiencia: %d\n\
{20D879}Dinheiro: $%d\n\
{00E5FF}Banco: $%d\n\
{FFFFFF}Emprego: %s\n\
{FFFFFF}Fome: %d/100\n\
{FFFFFF}Sede: %d/100\n\
{FFFFFF}CNH: %s",
        Nome[playerid],
        Dados[playerid][Nivel],
        Dados[playerid][Experiencia],
        Dados[playerid][Dinheiro],
        Dados[playerid][Banco],
        NomeEmprego(Dados[playerid][Emprego]),
        Dados[playerid][Fome],
        Dados[playerid][Sede],
        Dados[playerid][CNH] ? "Sim" : "Nao");

    ShowPlayerDialog(playerid, DIALOG_STATUS,
        DIALOG_STYLE_MSGBOX,
        "{9B5CFF}Meu personagem",
        StringTemporaria,
        "Fechar", "");
    return 1;
}

// ============================================================
// COMANDOS
// ============================================================

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!Dados[playerid][Logado])
        return 1;

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

    if (!strcmp(cmdtext, "/banco", true))
    {
        AbrirBanco(playerid);
        return 1;
    }

    if (!strcmp(cmdtext, "/trabalhar", true))
    {
        IniciarTrabalho(playerid);
        return 1;
    }

    if (!strcmp(cmdtext, "/finalizar", true))
    {
        FinalizarTrabalho(playerid);
        return 1;
    }

    if (!strcmp(cmdtext, "/status", true))
    {
        MostrarStatus(playerid);
        return 1;
    }

    if (!strcmp(cmdtext, "/salvar", true))
    {
        SalvarConta(playerid);
        Mensagem(playerid, COR_VERDE,
            "Sua conta foi salva.");
        return 1;
    }

    if (!strcmp(cmdtext, "/dono", true))
    {
        if (!EhDono(playerid))
        {
            Mensagem(playerid, COR_VERMELHO,
                "Comando exclusivo do dono.");
            return 1;
        }

        ShowPlayerDialog(playerid, DIALOG_DONO_LOGIN,
            DIALOG_STYLE_PASSWORD,
            "{FFD700}[DONO] Acesso administrativo",
            "Digite a senha administrativa:",
            "Entrar", "Cancelar");
        return 1;
    }

    if (!strcmp(cmdtext, "/comandos", true))
    {
        ShowPlayerDialog(playerid, 1013,
            DIALOG_STYLE_MSGBOX,
            "{9B5CFF}Comandos ZK RP",
            "/menu - Menu principal\n\
/empregos - Central de empregos\n\
/gps - GPS\n\
/banco - Banco\n\
/trabalhar - Iniciar trabalho\n\
/finalizar - Finalizar trabalho\n\
/status - Ver personagem\n\
/dono - Painel administrativo\n\
/salvar - Salvar conta",
            "Fechar", "");
        return 1;
    }

    return 0;
}

// ============================================================
// CALLBACKS PRINCIPAIS
// ============================================================

public OnGameModeInit()
{
    SetGameModeText(ZK_SERVIDOR);
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    ShowNameTags(true);
    SetWeather(10);
    SetWorldTime(12);

    AddPlayerClass(0, 1481.0, -1771.0, 18.8,
        90.0, 0, 0, 0, 0, 0, 0);

    InicializarCasas();

    SetTimer("AtualizarTodos", 60000, true);

    print("==================================");
    print(" ZK RP MOBILE INICIADO");
    print("==================================");

    return 1;
}

forward AtualizarTodos();
public AtualizarTodos()
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i) && Dados[i][Logado])
        {
            AtualizarNecessidades(i);
            SalvarConta(i);
        }
    }
    return 1;
}

public OnPlayerConnect(playerid)
{
    GetPlayerName(playerid, Nome[playerid],
        MAX_PLAYER_NAME);

    InicializarDados(playerid);

    Dados[playerid][VeiculoTrabalho] = INVALID_VEHICLE_ID;

    if (CarregarConta(playerid))
        MostrarLogin(playerid);
    else
        MostrarRegistro(playerid);

    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    #pragma unused reason

    if (Dados[playerid][Logado])
        SalvarConta(playerid);

    if (Dados[playerid][VeiculoTrabalho] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(Dados[playerid][VeiculoTrabalho]);
        Dados[playerid][VeiculoTrabalho] = INVALID_VEHICLE_ID;
    }

    return 1;
}

public OnPlayerSpawn(playerid)
{
    if (!Dados[playerid][Logado])
        return 1;

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid, 1481.0, -1771.0, 18.8);
    SetPlayerFacingAngle(playerid, 90.0);
    SetCameraBehindPlayer(playerid);

    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    #pragma unused killerid
    #pragma unused reason

    Dados[playerid][Trabalhando] = false;

    if (Dados[playerid][VeiculoTrabalho] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(Dados[playerid][VeiculoTrabalho]);
        Dados[playerid][VeiculoTrabalho] = INVALID_VEHICLE_ID;
    }

    return 1;
}

// ============================================================
// DIÁLOGOS - REGISTRO, LOGIN E MENUS
// ============================================================

public OnDialogResponse(playerid, dialogid, response,
    listitem, inputtext[])
{
    if (!response)
    {
        if (dialogid == DIALOG_REGISTRO ||
            dialogid == DIALOG_LOGIN)
        {
            Kick(playerid);
            return 1;
        }

        if (dialogid == DIALOG_MENU)
            return 1;

        return 0;
    }

    if (dialogid == DIALOG_REGISTRO)
    {
        if (strlen(inputtext) < 4)
        {
            Mensagem(playerid, COR_VERMELHO,
                "A senha precisa ter pelo menos 4 caracteres.");
            MostrarRegistro(playerid);
            return 1;
        }

        SHA256_PassHash(inputtext, Nome[playerid],
            Dados[playerid][SenhaHash], 65);

        Dados[playerid][Dinheiro] = DINHEIRO_INICIAL;
        Dados[playerid][Banco] = 0;
        Dados[playerid][Nivel] = 1;
        Dados[playerid][Experiencia] = 0;
        Dados[playerid][Fome] = 100;
        Dados[playerid][Sede] = 100;
        Dados[playerid][Emprego] = EMPREGO_NENHUM;
        Dados[playerid][Skin] = 0;
        Dados[playerid][CNH] = false;
        Dados[playerid][Casa] = -1;

        SalvarConta(playerid);
        EntrarNoServidor(playerid);
        return 1;
    }

    if (dialogid == DIALOG_LOGIN)
    {
        new hash[65];

        SHA256_PassHash(inputtext, Nome[playerid],
            hash, sizeof(hash));

        if (strcmp(hash, Dados[playerid][SenhaHash], false))
        {
            Mensagem(playerid, COR_VERMELHO,
                "Senha incorreta.");
            MostrarLogin(playerid);
            return 1;
        }

        EntrarNoServidor(playerid);
        return 1;
    }

    if (dialogid == DIALOG_MENU)
    {
        switch (listitem)
        {
            case 0: MostrarStatus(playerid);
            case 1: AbrirEmpregos(playerid);
            case 2: AbrirGPS(playerid);
            case 3: AbrirBanco(playerid);
            case 4:
            {
                ShowPlayerDialog(playerid, DIALOG_MERCADO,
                    DIALOG_STYLE_LIST,
                    "{9B5CFF}Mercado",
                    "Comida - $50\nAgua - $30",
                    "Comprar", "Voltar");
            }
            case 5:
            {
                ShowPlayerDialog(playerid, DIALOG_ROUPAS,
                    DIALOG_STYLE_LIST,
                    "{9B5CFF}Roupas e CNH",
                    "Comprar CNH - $1.000\nSkin 7\nSkin 15\nSkin 23\nSkin 29",
                    "Selecionar", "Voltar");
            }
            case 6: AbrirCasas(playerid);
            case 7:
            {
                ShowPlayerDialog(playerid, DIALOG_VEICULO,
                    DIALOG_STYLE_LIST,
                    "{9B5CFF}Veiculos",
                    "Ver meu veiculo de trabalho",
                    "Selecionar", "Voltar");
            }
        }
        return 1;
    }

    return 0;
}

// ============================================================
// PARTE 4/4 - DIALOGOS FINAIS E ENCERRAMENTO
// ============================================================

    if (dialogid == DIALOG_EMPREGOS)
    {
        switch (listitem)
        {
            case 0: Dados[playerid][Emprego] = EMPREGO_ENTREGADOR;
            case 1: Dados[playerid][Emprego] = EMPREGO_ONIBUS;
            case 2: Dados[playerid][Emprego] = EMPREGO_POLICIAL;
            case 3: Dados[playerid][Emprego] = EMPREGO_MECANICO;
            case 4: Dados[playerid][Emprego] = EMPREGO_NENHUM;
        }

        format(StringTemporaria, sizeof(StringTemporaria),
            "Seu emprego agora e: %s.",
            NomeEmprego(Dados[playerid][Emprego]));

        Mensagem(playerid, COR_VERDE, StringTemporaria);
        SalvarConta(playerid);
        return 1;
    }

    if (dialogid == DIALOG_GPS)
    {
        switch (listitem)
        {
            case 0: SetPlayerCheckpoint(playerid, 1481.0, -1771.0, 18.8, 5.0);
            case 1: SetPlayerCheckpoint(playerid, 1368.0, -1279.0, 13.5, 5.0);
            case 2: SetPlayerCheckpoint(playerid, 1642.0, -1521.0, 13.5, 5.0);
            case 3: SetPlayerCheckpoint(playerid, 2070.0, -1791.0, 13.5, 5.0);
            case 4: SetPlayerCheckpoint(playerid, 1172.0, -1323.0, 15.4, 5.0);
            case 5:
            {
                if (Dados[playerid][Casa] >= 0 &&
                    Dados[playerid][Casa] < MAX_CASAS)
                {
                    new casa = Dados[playerid][Casa];

                    SetPlayerCheckpoint(playerid,
                        Casas[casa][CasaX],
                        Casas[casa][CasaY],
                        Casas[casa][CasaZ], 5.0);
                }
                else
                {
                    Mensagem(playerid, COR_VERMELHO,
                        "Voce nao possui uma casa.");
                }
            }
            case 6: DisablePlayerCheckpoint(playerid);
        }

        Mensagem(playerid, COR_CIANO,
            "GPS atualizado.");
        return 1;
    }

    if (dialogid == DIALOG_BANCO)
    {
        switch (listitem)
        {
            case 0:
            {
                if (RetirarDinheiro(playerid, 500))
                    Dados[playerid][Banco] += 500;
            }
            case 1:
            {
                if (RetirarDinheiro(playerid, 1000))
                    Dados[playerid][Banco] += 1000;
            }
            case 2:
            {
                if (Dados[playerid][Banco] >= 500)
                {
                    Dados[playerid][Banco] -= 500;
                    Dados[playerid][Dinheiro] += 500;
                }
                else Mensagem(playerid, COR_VERMELHO,
                    "Saldo bancario insuficiente.");
            }
            case 3:
            {
                if (Dados[playerid][Banco] >= 1000)
                {
                    Dados[playerid][Banco] -= 1000;
                    Dados[playerid][Dinheiro] += 1000;
                }
                else Mensagem(playerid, COR_VERMELHO,
                    "Saldo bancario insuficiente.");
            }
            case 4:
            {
                format(StringTemporaria, sizeof(StringTemporaria),
                    "Dinheiro: $%d\nBanco: $%d",
                    Dados[playerid][Dinheiro],
                    Dados[playerid][Banco]);

                ShowPlayerDialog(playerid, 1014,
                    DIALOG_STYLE_MSGBOX,
                    "{9B5CFF}Saldo bancario",
                    StringTemporaria,
                    "Fechar", "");
            }
        }

        SalvarConta(playerid);
        AbrirBanco(playerid);
        return 1;
    }

    if (dialogid == DIALOG_CASAS)
    {
        if (listitem < 0 || listitem >= MAX_CASAS)
            return 1;

        if (Casas[listitem][Comprada])
        {
            Mensagem(playerid, COR_VERMELHO,
                "Esta casa ja foi comprada.");
            return 1;
        }

        if (!RetirarDinheiro(playerid, Casas[listitem][Preco]))
        {
            Mensagem(playerid, COR_VERMELHO,
                "Voce nao tem dinheiro suficiente.");
            return 1;
        }

        Casas[listitem][Comprada] = true;

        format(Casas[listitem][Dono],
            MAX_PLAYER_NAME, "%s", Nome[playerid]);

        Dados[playerid][Casa] = listitem;

        Mensagem(playerid, COR_VERDE,
            "Parabens! Voce comprou uma casa.");

        SalvarConta(playerid);
        return 1;
    }

    if (dialogid == DIALOG_MERCADO)
    {
        if (listitem == 0)
        {
            if (RetirarDinheiro(playerid, 50))
            {
                Dados[playerid][Fome] += 25;
                if (Dados[playerid][Fome] > 100)
                    Dados[playerid][Fome] = 100;

                Mensagem(playerid, COR_VERDE,
                    "Voce comprou comida.");
            }
        }
        else if (listitem == 1)
        {
            if (RetirarDinheiro(playerid, 30))
            {
                Dados[playerid][Sede] += 25;
                if (Dados[playerid][Sede] > 100)
                    Dados[playerid][Sede] = 100;

                Mensagem(playerid, COR_VERDE,
                    "Voce comprou agua.");
            }
        }

        SalvarConta(playerid);
        return 1;
    }

    if (dialogid == DIALOG_ROUPAS)
    {
        if (listitem == 0)
        {
            if (!Dados[playerid][CNH])
            {
                if (RetirarDinheiro(playerid, 1000))
                {
                    Dados[playerid][CNH] = true;
                    Mensagem(playerid, COR_VERDE,
                        "Sua CNH foi liberada.");
                }
            }
            else
            {
                Mensagem(playerid, COR_CIANO,
                    "Voce ja possui CNH.");
            }
        }
        else
        {
            new skins[] = {7, 15, 23, 29};
            new skin = skins[listitem - 1];

            if (RetirarDinheiro(playerid, 300))
            {
                Dados[playerid][Skin] = skin;
                SetPlayerSkin(playerid, skin);

                Mensagem(playerid, COR_VERDE,
                    "Roupa comprada e equipada.");
            }
        }

        SalvarConta(playerid);
        return 1;
    }

    if (dialogid == DIALOG_VEICULO)
    {
        if (Dados[playerid][VeiculoTrabalho] != INVALID_VEHICLE_ID &&
            IsValidVehicle(Dados[playerid][VeiculoTrabalho]))
        {
            new Float:x, Float:y, Float:z;

            GetVehiclePos(Dados[playerid][VeiculoTrabalho],
                x, y, z);

            SetPlayerPos(playerid, x + 2.0, y, z);
            Mensagem(playerid, COR_CIANO,
                "Voce foi ate seu veiculo de trabalho.");
        }
        else
        {
            Mensagem(playerid, COR_VERMELHO,
                "Voce nao possui veiculo de trabalho ativo.");
        }
        return 1;
    }

    if (dialogid == DIALOG_DONO_LOGIN)
    {
        if (!EhDono(playerid))
            return 1;

        if (strcmp(inputtext, ZK_SENHA_DONO, false))
        {
            Mensagem(playerid, COR_VERMELHO,
                "Senha administrativa incorreta.");
            return 1;
        }

        AbrirPainelDono(playerid);
        return 1;
    }

    if (dialogid == DIALOG_DONO)
    {
        if (!EhDono(playerid))
            return 1;

        switch (listitem)
        {
            case 0: CriarVeiculoDono(playerid, 560);
            case 1: CriarVeiculoDono(playerid, 411);
            case 2: CriarVeiculoDono(playerid, 522);
            case 3: SetPlayerPos(playerid, 1481.0, -1771.0, 18.8);
            case 4: SetPlayerPos(playerid, 1368.0, -1279.0, 13.5);
            case 5: SetPlayerHealth(playerid, 100.0);
            case 6:
            {
                Dados[playerid][Dinheiro] += 10000;
                GivePlayerMoney(playerid, 10000);
                SalvarConta(playerid);
            }
            case 7: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
            case 8: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        }

        Mensagem(playerid, COR_DOURADO,
            "[DONO] Acao administrativa executada.");
        return 1;
    }

    return 0;
}

// ============================================================
// CHECKPOINTS E FINALIZACAO
// ============================================================

public OnPlayerEnterCheckpoint(playerid)
{
    if (!Dados[playerid][Logado])
        return 1;

    DisablePlayerCheckpoint(playerid);

    Mensagem(playerid, COR_VERDE,
        "Voce chegou ao destino marcado no GPS.");

    return 1;
}

public OnPlayerText(playerid, text[])
{
    if (!Dados[playerid][Logado])
        return 0;

    if (EhDono(playerid))
    {
        format(StringTemporaria, sizeof(StringTemporaria),
            "{FFD700}[DONO] {FFFFFF}%s: %s",
            Nome[playerid], text);
    }
    else
    {
        format(StringTemporaria, sizeof(StringTemporaria),
            "{FFFFFF}%s: %s",
            Nome[playerid], text);
    }

    SendClientMessageToAll(COR_BRANCO, StringTemporaria);
    return 0;
}

// ============================================================
// FIM DO GAMEMODE ZK RP MOBILE
// ============================================================
