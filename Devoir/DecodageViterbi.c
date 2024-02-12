#include <stdio.h>
#include <string.h>
#define L 12  /* longueur du message en bits */
#define N 4  /* nombre d'états du code */

// Message de test pré-encodé
static const unsigned int bitsrc[L] = { 5, 6, 2, 3, 1, 7, 0, 5, 3, 1, 2, 6 };

// Métriques pour le treilli serré.  
// Voir section 3.2 de l'Annexe sur Viterbi pour explications.
//
//
// 1ère matrice de métriques pour le treilli serré
static const unsigned int pr1[N][N] = {
        {0,7,6,1},
        {5,2,3,4},
        {0,7,6,1},
        {5,2,3,4}
    };
// 2e matrice de métriques pour le treilli serré
static const unsigned int pr2[N][N] = {
        {0,0,7,7},
        {6,6,1,1},
        {5,5,2,2},
        {3,3,4,4}
    };

// Exemple (lié à la figure 1.2 de l'annexe Viterbi).
// Soit une transition 0x0 --> 0x2 --> 0x3 dans le treilli régulier.
// La figure 1.2 de l'Annexe A montre que les codes de transitions sont 0x5 et 0x3
// Dans le treilli serré, la transition 0x0 --> 0x3 est équivalente, et
// s'attend aux mêmes codes, que l'on retrouve dans pr1 et pr2:
// pr1[0][3] = 5;
// pr2[0][3] = 3;


// compte le nombre de bits à '1' sur les 4 bits les moins significatifs
unsigned int popcount4( unsigned int a)
{
  return( (a >> 3 & 1) + (a >> 2 & 1) + (a >> 1 & 1) + (a & 1));
}

// Calcul la métrique pour un treilli serré
void genmetrique(unsigned int br1, unsigned int br2, unsigned int *m)
{
    unsigned int i, j;
    
    for (i=0; i < N; i++) {
        for (j=0; j < N; j++) {
			m[i*N+j] =   popcount4(br1 ^ pr1[i][j]) 
					   + popcount4(br2 ^ pr2[i][j]);
		}
    }
}

// Pour le devoir: Conserver la distinction entre les 2 fonctions!

// Somme/comparaison/sélection (add/compare/select)
// Paramètres: métriques, survivants en entrée, survivants en sortie
void acs(unsigned *met, int *sinput, int *soutput)
{
	unsigned int temp, j;
	for(j=0; j< N; j++) {
			temp = met[j]+sinput[j];
			*soutput = temp < *soutput ? temp : *soutput;
		}
}

// Calcul des survivant, 
void CalculSurvivants( unsigned int *met, int *sinput, int *soutput)
{
	unsigned int i;  
	for (i=0; i< N; i++) {
		soutput[i]=250;
		acs(&met[i*N], sinput, &soutput[i]);
	}
}

// Point d'entrée du programme
int main()
{
	// variables à passer à ACS. Peuvent êtres placées directement 
	// en mémoire dans l'assembleur
    int si[N], so[N];
    unsigned int metriques[N][N];
	
	// variable locale
	int i;
    
	// Initialisation
    for (i=0; i<N; i++) {
		si[i] = 0;
    }
	
	// Exécution - pour chaque code du message
    for (i=0; i < L; i++) {
		// Treilli serré, donc à tous les deux codes
		if (i%2 != 0) {
			genmetrique( bitsrc[i-1], bitsrc[i], &metriques[0][0] );
			CalculSurvivants( &metriques[0][0], &si[0], &so[0] );
			
			// Copie pour le prochain cycle
			memcpy(si, so, sizeof(si));
		}
	}
    for (i=0; i < N; i++) {
		printf( "%d ", so[i] ); 
	}
    printf("\n");
    return 0;
}
