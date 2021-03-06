This file describes edits made to parflow scripts in cvoter_dev branch and the logic behind those edits.

To check for string within files, use grep recursively:

    grep -R 'swe' parflow/

# Print canopy water storage (h20can)

clm%h2ocan (in CLM files) --> "can", "can_out", etc. (in PF files). Can generally search for "clm%h2osno", "swe", "swe_out" and follow name conventions for that flux.

To ensure clm test pass (during make check), create directory "can_out" within the parflow test directory (i.e., parflow/test/clm/can_out) in order for clm tests to pass.

Files to edit include:

## pfsimulator/clm/clm.F90

1. Add "can_pf" to subroutine clm_lsm(pressure,saturation,...clm_daily_rst)
2. Around line 96: declare local variable  
	real(r8) :: can_pf((nx+2)*(ny+2)*3)            ! can
3. Around line 574: set local variable equal to clm variable  
	can_pf(l)          = clm(t)%h2ocan
4. Around line 591: do this again in the else part of the statement  
	can_pf(l)          = -9999.0

## pfsimulator/clm/open_files.F90
1. Around line 73: add output directory for h2ocan  
     open(2010,file=clm_output_dir//'can_out.'//cistep//'.bin.'//trim(adjustl(RI)), access=ACCESS, form=FORM) ! @ 2D output file  
     write(2010) ix,iy,iz,drv%nc,drv%nr,nz  
2. Around line 127: add output directory for h2ocan  
     open(2010,file=clm_output_dir//'can_out/can_out.'//cistep//'.bin.'//trim(adjustl(RI)), access=ACCESS, form=FORM) ! @ 2D output file  
     write(2010) ix,iy,iz,drv%nc,drv%nr,nz  

## pfsimulator/clm/close_files.F90
1. Add close(2010) to end of list.

## pfsimulator/parflow_lib/parflow_proto_f.h
1. Around line 130: correct sequence for CLM_LSM(pressure....clm_daily_rst)
add "can_out_data" wherever see "swe_out_data" (should be 3x)

## pfsimulator/parflow_lib/solver_richards.c
1. Around line 248: declare local vars for pf printing of clm output  
	Vector      *can_out;              /* canopy water equivalent [mm] */
2. Around line 745: initialize variables for printing CLM output  
	instance_xtra -> can_out = NewVectorType( grid2d, 1, 1, vector_cell_centered_2D );  
	InitVectorAll(instance_xtra -> can_out, 0.0);  
3. Around line 1411: Subvector & double for writing CLM output  
	Subvector    *eflx_lh_tot_sub,....  
	double       *eflx_lh,...  
4. Around line 1979: Subvectors for CLM fluxes  
	can_out_sub        = VectorSubvector(instance_xtra -> can_out,is);  
5. Around line 2042: Subvector data for CLM fluxes  
	can                = SubvectorData(can_out_sub);  
6. Around line 2166: CALL_CLM_LSM(pp...clm_daily_restart)  
7. Around line 3099: Print CLM output files  
	sprintf(file_type, "can_out");  
	WriteSilo(file_prefix, file_type, file_postfix, instance_xtra -> can_out,  
		t, instance_xtra -> file_number, "CAN");  
	clm_file_dumped = 1;  
7. Around line 3190: Write CLMNC files  
        WriteCLMNC(file_prefix, nc_postfix, t, instance_xtra->can_out,  
                   public_xtra->numCLMVarTimeVariant, "can_out", 2);  
8. Around line 3241: Single file output (not 100% sure how no. of lines change)  
	PFVLayerCopy(11, 0, instance_xtra -> clm_out_grid, instance_xtra -> can_out);  
	Also adjust existing layer 11, 12, and 13+k.  
9. Around line 3338: Multifile output  
	sprintf(file_postfix, "can_out.%05d", instance_xtra -> file_number );  
	WritePFBinary(file_prefix, file_postfix, instance_xtra -> can_out );  
	clm_file_dumped = 1;  
10. Around line 3685: FreeVector for CLM data  
	FreeVector(instance_xtra -> can_out);  

## pfsimulator/parflow_lib/write_parflow_silo.c
1. Around line 282: add "can" to list of output types  
	"can_out",
