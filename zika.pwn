
#include <a_samp>

// ============================================================
// ZK RP MOBILE - GAMEMODE RECONSTRUIDO
// ============================================================

#define ZK_SERVIDOR "ZK RP | Mobile Roleplay"
#define ZK_DONO "Fhzk"
#define ZK_SENHA_DONO "TROQUE_POR_UMA_SENHA_PRIVADA"

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
