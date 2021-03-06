/********************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or 
modify it under the terms of the GNU General Public License as 
published by the Free Software Foundation; either version 2 (1991) of
the License, or any later version. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even 
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details

*********************************************************************

File   : complex_coherence_opt_estimation.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2012
Update  :
*--------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164

Image and Remote Sensing Group
SAPHIR Team 
(SAr Polarimetry Holography Interferometry Radargrammetry)

UNIVERSITY OF RENNES I
B�t. 11D - Campus de Beaulieu
263 Avenue G�n�ral Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail: eric.pottier@univ-rennes1.fr

*--------------------------------------------------------------------

Description :  Interferometric Complex Coherence determination

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ALIASES  */

/* CONSTANTS  */

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

#define NPolType 2
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2T6", "T6"};
  FILE *out_file1, *out_file2, *out_file3;
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col, k, l;
  
/* Matrix arrays */
  cplx **TT11,**TT12,**TT22;
  cplx **iTT11,**hTT12,**iTT22;
  cplx **Tmp11,**Tmp12, **Tmp22, **Tmp;
  cplx **V1, **hV1, **V2, **hV2;
  float *L, *phi;

/* Matrix arrays */
  float ***S_in1;
  float ***S_in2;
  float ***M_in;
  float *Mean;
  float **M_out1;
  float **M_out2;
  float **M_out3;
  float *Buffer;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncomplex_coherence_opt_estimation.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," if iodf = S2T6\n");
strcat(UsageHelp," (string)	-idm 	input master directory\n");
strcat(UsageHelp," (string)	-ids 	input slave directory\n");
strcat(UsageHelp," if iodf = T6\n");
strcat(UsageHelp," (string)	-id  	input master-slave directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (int)   	-mem 	Allocated memory for blocksize determination (in Mb)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

/********************************************************************
********************************************************************/

strcpy(UsageHelpDataFormat,"\nPolarimetric Input-Output Data Format\n\n");
for (ii=0; ii<NPolType; ii++) CreateUsageHelpDataFormat(PolTypeConf[ii]); 
strcat(UsageHelpDataFormat,"\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }
if(get_commandline_prm(argc,argv,"-data",no_cmd_prm,NULL,0,UsageHelpDataFormat)) {
  printf("\n Usage:\n%s\n",UsageHelpDataFormat); exit(1);
  }

if(argc < 19) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  if (strcmp(PolType, "S2T6") == 0) {
    get_commandline_prm(argc,argv,"-idm",str_cmd_prm,in_dir1,1,UsageHelp);
    get_commandline_prm(argc,argv,"-ids",str_cmd_prm,in_dir2,1,UsageHelp);
    }
  if (strcmp(PolType, "T6") == 0) {
    get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir1,1,UsageHelp);
    strcpy(in_dir2,in_dir1);
    }
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1;
  get_commandline_prm(argc,argv,"-mem",int_cmd_prm,&MemoryAlloc,0,UsageHelp);
  MemoryAlloc = my_max(MemoryAlloc,1000);

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

/***********************************************************************
***********************************************************************/

  check_dir(in_dir1);
  if (strcmp(PolType, "S2T6") == 0) check_dir(in_dir2);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir1, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in1 = matrix_char(NpolarIn,1024); 
  if (strcmp(PolTypeIn,"S2")==0) file_name_in2 = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir1, file_name_in1);
  if (strcmp(PolTypeIn,"S2")==0) init_file_name(PolTypeIn, in_dir2, file_name_in2);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile1[Np] = fopen(file_name_in1[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in1[Np]);
      
  if (strcmp(PolTypeIn,"S2")==0)
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile2[Np] = fopen(file_name_in2[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in2[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%scmplx_coh_Opt1.bin", out_dir);
  if ((out_file1 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%scmplx_coh_Opt2.bin", out_dir);
  if ((out_file2 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%scmplx_coh_Opt3.bin", out_dir);
  if ((out_file3 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
   
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask */ 
  NBlockA += Sub_Ncol+NwinC; NBlockB += NwinL*(Sub_Ncol+NwinC);

  if (strcmp(PolTypeIn,"S2")==0) {
    /* Sin = NpolarIn*Nlig*2*Ncol */
    NBlockA += 2*NpolarIn*2*(Ncol+NwinC); NBlockB += 2*NpolarIn*NwinL*2*(Ncol+NwinC);
    }

  /* Min = NpolarOut*(Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mout = Nlig*2*Sub_Ncol : 1 to 4*/
  NBlockA += 2*Sub_Ncol; NBlockB += 0;
  NBlockA += 2*Sub_Ncol; NBlockB += 0;
  NBlockA += 2*Sub_Ncol; NBlockB += 0;
  /* Buffer = NpolarOut */
  NBlockA += 0; NBlockB += NpolarOut;
  /* Mean = NpolarOut */
  NBlockA += 0; NBlockB += NpolarOut;
  
/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, NwinL, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

/* MATRIX ALLOCATION */
  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  if (strcmp(PolTypeIn,"S2")==0) {
    S_in1 = matrix3d_float(NpolarIn, NligBlock[0] + NwinL, 2*(Ncol + NwinC));
    S_in2 = matrix3d_float(NpolarIn, NligBlock[0] + NwinL, 2*(Ncol + NwinC));
    }

  M_in = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  M_out1 = matrix_float(NligBlock[0], 2*Sub_Ncol);
  M_out2 = matrix_float(NligBlock[0], 2*Sub_Ncol);
  M_out3 = matrix_float(NligBlock[0], 2*Sub_Ncol);
  Mean = vector_float(NpolarOut);

  TT11  = cplx_matrix(3,3);
  TT12  = cplx_matrix(3,3);
  TT22  = cplx_matrix(3,3);
  iTT11  = cplx_matrix(3,3);
  hTT12  = cplx_matrix(3,3);
  iTT22  = cplx_matrix(3,3);
  Tmp11  = cplx_matrix(3,3);
  Tmp12  = cplx_matrix(3,3);
  Tmp22  = cplx_matrix(3,3);
  Tmp  = cplx_matrix(3,3);
  V1  = cplx_matrix(3,3);
  hV1  = cplx_matrix(3,3);
  V2  = cplx_matrix(3,3);
  hV2  = cplx_matrix(3,3);
  L  = vector_float(3);
  phi  = vector_float(3);

  Buffer = vector_float(NpolarOut);
  
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0] + NwinL; lig++) 
      for (col = 0; col < Sub_Ncol + NwinC; col++) 
        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (strcmp(PolTypeIn,"S2")==0) {
    read_block_S2_noavg(in_datafile1, S_in1, "S2", 4, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    read_block_S2_noavg(in_datafile2, S_in2, "S2", 4, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

    S2_to_T6(S_in1, S_in2, M_in, NligBlock[Nb] + NwinL, Sub_Ncol + NwinC, 0, 0);

    } else {
    /* Case of T6 */
    read_block_TCI_noavg(in_datafile1, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      M_out1[lig][2*col] = 0.; M_out1[lig][2*col+1] = 0.;
      M_out2[lig][2*col] = 0.; M_out2[lig][2*col+1] = 0.;
      M_out3[lig][2*col] = 0.; M_out3[lig][2*col+1] = 0.;
      if (col == 0) {
        Nvalid = 0.;
        for (Np = 0; Np < NpolarOut; Np++) Buffer[Np] = 0.; 
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
          for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
            for (Np = 0; Np < NpolarOut; Np++)
              Buffer[Np] = Buffer[Np] + M_in[Np][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            Nvalid = Nvalid + Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            }
        } else {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
          for (Np = 0; Np < NpolarOut; Np++) {
            Buffer[Np] = Buffer[Np] - M_in[Np][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            Buffer[Np] = Buffer[Np] + M_in[Np][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            }
          Nvalid = Nvalid - Valid[NwinLM1S2+lig+k][col-1] + Valid[NwinLM1S2+lig+k][NwinC-1+col];
          }
        }      
      if (Nvalid != 0.) for (Np = 0; Np < NpolarOut; Np++) Mean[Np] = Buffer[Np]/Nvalid;

    if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
      TT11[0][0].re = Mean[0];  TT11[0][0].im = 0;
      TT11[0][1].re = Mean[1];  TT11[0][1].im = Mean[2];
      TT11[0][2].re = Mean[3];  TT11[0][2].im = Mean[4];
      TT11[1][1].re = Mean[11]; TT11[1][1].im = 0;
      TT11[1][2].re = Mean[12]; TT11[1][2].im = Mean[13];
      TT11[2][2].re = Mean[20]; TT11[2][2].im = 0;
      TT11[1][0].re = TT11[0][1].re;  TT11[1][0].im = -TT11[0][1].im;
      TT11[2][0].re = TT11[0][2].re;  TT11[2][0].im = -TT11[0][2].im;
      TT11[2][1].re = TT11[1][2].re;  TT11[2][1].im = -TT11[1][2].im;

      TT22[0][0].re = Mean[27]; TT22[0][0].im = 0;
      TT22[0][1].re = Mean[28]; TT22[0][1].im = Mean[29];
      TT22[0][2].re = Mean[30]; TT22[0][2].im = Mean[31];
      TT22[1][1].re = Mean[32]; TT22[1][1].im = 0;
      TT22[1][2].re = Mean[33]; TT22[1][2].im = Mean[34];
      TT22[2][2].re = Mean[35]; TT22[2][2].im = 0;
      TT22[1][0].re = TT22[0][1].re;  TT22[1][0].im = -TT22[0][1].im;
      TT22[2][0].re = TT22[0][2].re;  TT22[2][0].im = -TT22[0][2].im;
      TT22[2][1].re = TT22[1][2].re;  TT22[2][1].im = -TT22[1][2].im;
    
      TT12[0][0].re = Mean[5];  TT12[0][0].im = Mean[6];
      TT12[0][1].re = Mean[7];  TT12[0][1].im = Mean[8];
      TT12[0][2].re = Mean[9];  TT12[0][2].im = Mean[10];
      TT12[1][0].re = Mean[14]; TT12[1][0].im = Mean[15];
      TT12[1][1].re = Mean[16]; TT12[1][1].im = Mean[17];
      TT12[1][2].re = Mean[18]; TT12[1][2].im = Mean[19];
      TT12[2][0].re = Mean[21]; TT12[2][0].im = Mean[22];
      TT12[2][1].re = Mean[23]; TT12[2][1].im = Mean[24];
      TT12[2][2].re = Mean[25]; TT12[2][2].im = Mean[26];
  
      cplx_htransp_mat(TT12,hTT12,3,3);
      cplx_inv_mat(TT11,iTT11);
      cplx_inv_mat(TT22,iTT22);

      //Eigenvectors V2
      cplx_mul_mat(iTT22,hTT12,Tmp11,3,3);
      cplx_mul_mat(Tmp11,iTT11,Tmp22,3,3);
      cplx_mul_mat(Tmp22,TT12,Tmp11,3,3);
      cplx_diag_mat3(Tmp11,V2,L);

      //Eigenvectors V1
      cplx_mul_mat(iTT11,TT12,Tmp11,3,3);
      cplx_mul_mat(Tmp11,iTT22,Tmp22,3,3);
      cplx_mul_mat(Tmp22,hTT12,Tmp11,3,3);
      cplx_diag_mat3(Tmp11,V1,L);

      //Eigen Phase Correction
      cplx_htransp_mat(V1,hV1,3,3);
      cplx_mul_mat(hV1,V2,Tmp11,3,3);
      for (k=0; k<3; k++)  phi[k] = angle(Tmp11[k][k]);

      //Eigen Phase Normalized Eigenvectors V2 with (-phi)
      for (k=0; k<3; k++) {
        for (l=0; l<3; l++) {  
          Tmp22[k][l].re = 0.; Tmp22[k][l].im = 0.;
          }
        Tmp22[k][k].re = cos(phi[k]);
        Tmp22[k][k].im = -sin(phi[k]);
        }
      cplx_mul_mat(V2,Tmp22,Tmp11,3,3);
      for (k=0; k<3; k++) {
        for (l=0; l<3; l++) {  
          V2[k][l].re = Tmp11[k][l].re;
          V2[k][l].im = Tmp11[k][l].im;
          }
        }
      cplx_htransp_mat(V2,hV2,3,3);

      cplx_mul_mat(TT12,V2,Tmp,3,3);
      cplx_mul_mat(hV1,Tmp,Tmp12,3,3);

      cplx_mul_mat(TT11,V1,Tmp,3,3);
      cplx_mul_mat(hV1,Tmp,Tmp11,3,3);

      cplx_mul_mat(TT22,V2,Tmp,3,3);
      cplx_mul_mat(hV2,Tmp,Tmp22,3,3);

      M_out1[lig][2*col] = Tmp12[0][0].re / sqrt(cmod(Tmp11[0][0]) * cmod(Tmp22[0][0]));
      M_out1[lig][2*col+1] = Tmp12[0][0].im / sqrt(cmod(Tmp11[0][0]) * cmod(Tmp22[0][0]));
      if(isnan(M_out1[lig][2*col])+isnan(M_out1[lig][2*col+1])) {
        M_out1[lig][2*col]=1.; M_out1[lig][2*col+1]=0.;
        }
      M_out2[lig][2*col] = Tmp12[1][1].re / sqrt(cmod(Tmp11[1][1]) * cmod(Tmp22[1][1]));
      M_out2[lig][2*col+1] = Tmp12[1][1].im / sqrt(cmod(Tmp11[1][1]) * cmod(Tmp22[1][1]));
      if(isnan(M_out2[lig][2*col])+isnan(M_out2[lig][2*col+1])) {
        M_out2[lig][2*col]=1.; M_out2[lig][2*col+1]=0.;
        }
      M_out3[lig][2*col] = Tmp12[2][2].re / sqrt(cmod(Tmp11[2][2]) * cmod(Tmp22[2][2]));
      M_out3[lig][2*col+1] = Tmp12[2][2].im / sqrt(cmod(Tmp11[2][2]) * cmod(Tmp22[2][2]));
      if(isnan(M_out3[lig][2*col])+isnan(M_out3[lig][2*col+1])) {
        M_out3[lig][2*col]=1.; M_out3[lig][2*col+1]=0.;
        }
        }
      }    /*col */
    }

  write_block_matrix_float(out_file1, M_out1, NligBlock[Nb], 2*Sub_Ncol, 0, 0, 2*Sub_Ncol);
  write_block_matrix_float(out_file2, M_out2, NligBlock[Nb], 2*Sub_Ncol, 0, 0, 2*Sub_Ncol);
  write_block_matrix_float(out_file3, M_out3, NligBlock[Nb], 2*Sub_Ncol, 0, 0, 2*Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  if (strcmp(PolTypeIn,"S2")==0) {
    free_matrix3d_float(S_in1, NpolarIn, NligBlock[0] + NwinL);
    free_matrix3d_float(S_in2, NpolarIn, NligBlock[0] + NwinL);
    }

  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + NwinL);
  free_matrix_float(M_out1, NligBlock[0]);
  free_matrix_float(M_out2, NligBlock[0]);
  free_matrix_float(M_out3, NligBlock[0]);
  free_vector_float(Mean);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(out_file1); fclose(out_file2); fclose(out_file3); 

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile1[Np]);
  if (strcmp(PolTypeIn,"S2")==0)
    for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile2[Np]);

/********************************************************************
********************************************************************/

  return 1;
}




