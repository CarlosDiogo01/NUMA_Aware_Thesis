#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <omp.h>

double** geraMatriz (int nLinhas, int nCols, int nnz) {
	int i, j, x, y, aux, cont;
	double **mat = (double **) calloc (nLinhas, sizeof(double*));
	double **coo = (double **) calloc (nLinhas, sizeof(double*));
	double valRand;

	for (i=0; i<nLinhas; i++) {
		mat[i] = (double*) calloc (nCols, sizeof(double));
	}

	srand(1);
	for (i=0; i<nnz; i += aux) {
		x = rand() % nLinhas;
		y = rand() % nCols;
		if (mat[x][y] == 0.0) {
			while ((valRand = (rand() % 50) * 0.25) == 0) {;}
			mat[x][y] = valRand; 
			aux = 1;
		} else {
			aux = 0;
		}
	}

	for (i=0; i<nLinhas; i++) {
		cont = 0;

		for(j=0; j<nCols; j++) { if (mat[i][j] != 0.0) {cont++;} }
		if (cont>0) {
			coo[i] = (double*) calloc ((cont*2)+1, sizeof(double));
			coo[i][0] = cont * 2;
			aux = 1;
			for (j=0; j<nCols; j++) {
				if (mat[i][j] != 0.0) {
					coo[i][aux] = j;
					coo[i][aux+1] = mat[i][j];
					aux += 2;
				}
			}
		} else {
			coo[i] = (double*) calloc (1, sizeof(double));
			coo[i][0] = 0;
		}
		free(mat[i]);
	}
	free(mat);

	return coo;
}

double** geraVetor (int nCols) {
	int i;
	double **vect = (double**) calloc (1, sizeof(double*));
	vect[0] = (double*) calloc (nCols, sizeof(double));
	srand(1);
	for(i=0; i<nCols; i++) {
		vect[0][i] = (rand() % 20) * 0.25;
	}

	return vect;
}

int main(int argc, char *argv[]) {
	unsigned int i, j, n, nnz, nLinhas, nCols, nLinhas_vect;
	double startTime, finalTime;
	double **coo, **vect, *result; 
	double soma;

	/* Preenchimento Matriz */
	nLinhas = atoi(argv[1]);
	nCols = atoi(argv[2]);
	nnz = (nLinhas * nCols) * 0.25;
	coo = geraMatriz(nLinhas, nCols, nnz);

	/* Preenchimento Vector */
	nLinhas_vect = atoi(argv[3]);
	vect = geraVetor(nLinhas_vect);

	/* Multiplicacao */
	result = (double*) calloc (nLinhas, sizeof(double));
	omp_set_num_threads(atoi(argv[4]));

	startTime = omp_get_wtime();	
	#pragma omp parallel 
	{ 
	#pragma omp for 
	for(i=0; i<nLinhas; i++){
		//printf("Ciclo_Thread:%d iteração:%d paralelo:%d\n", omp_get_thread_num(),i, omp_in_parallel());
		soma=0;
		n = coo[i][0];

		for(j=1; j<=n; j+=2){
			soma += coo[i][j+1]*vect[0][(int)coo[i][j]];
		}
		result[i] = soma;
	}
	}
	finalTime = omp_get_wtime();
	
	//printf("Fim do ciclo_Paralelo? %d\n", omp_in_parallel());

	/* Visualizacao dos resultados */
/*	printf("---------Matriz formato COO---------\n");
	for(i=0; i<nLinhas; i++){
		if (coo[i]) {
			n = coo[i][0];
			for(j=1; j<=n; j+=2) {
				printf("%f %f %f\n", (double)i,(double)coo[i][j], (double)coo[i][j+1]);
			}
		}
	}
	
	printf("\n---------Vetor---------\n");
	for(i=0; i<nLinhas_vect; i++) {
		printf("%f\n", vect[0][i]);
	}
	
	printf("-----------Resultado Multiplicacao---------\n");
	for(i=0; i<nLinhas; i++)
		printf("%f\n", result[i]);
*/
	printf("Time parallel: %.12f\n",(finalTime - startTime)*1000);

	/* Libertar a memoria alocada*/
	for(i=0; i<nLinhas; i++) {
		free(coo[i]);
	}
	free(coo);
	free(vect[0]);
	free(vect);
	free(result);

	return 0;
}
