
#include <a_samp>

// ============================================================================
// ZK RP MOBILE - GAMEMODE INTEGRADO
// SA-MP / open.mp - base nativa
// ============================================================================

#define ZK_SERVIDOR "ZK RP | Mobile Roleplay"
#define ZK_DONO "Fhzk"
#define ZK_SENHA_DONO "TROQUE_ESSA_SENHA_ANTES_DE_PUBLICAR"

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
