*============================================================================
* Utility file for path management in 20295 Microeconometrics Problem Sets
* This file should be included at the beginning of each problem set script
*============================================================================

* Find project root directory automatically
capture program drop find_project_root
program define find_project_root
    * Try to find README.md to identify project root
    local current_dir = c(pwd)
    local found = 0
    local max_levels = 5
    local level = 0
    
    while `level' <= `max_levels' & `found' == 0 {
        capture confirm file "README.md"
        if _rc == 0 {
            * Check if this README contains the project identifier
            tempname fh
            file open `fh' using "README.md", read text
            file read `fh' line
            file close `fh'
            if strpos("`line'", "20295") > 0 {
                global project_root = c(pwd)
                local found = 1
            }
        }
        if `found' == 0 {
            if `level' < `max_levels' {
                cd ..
                local level = `level' + 1
            }
            else {
                * Fallback: assume we're in a subdirectory
                cd "`current_dir'"
                global project_root = c(pwd)
                * Try to go up one level as a reasonable guess
                capture cd ..
                capture confirm file "README.md"
                if _rc == 0 {
                    global project_root = c(pwd)
                }
                else {
                    cd "`current_dir'"
                    global project_root = c(pwd)
                }
                local found = 1
            }
        }
    }
    
    * Set up standard paths relative to project root
    global data_dir "${project_root}/data"
    global data_raw "${data_dir}/raw"
    global data_interim "${data_dir}/interim"
    global data_processed "${data_dir}/processed"
    global outputs_dir "${project_root}/outputs"
    global outputs_figures "${outputs_dir}/figures"
    global outputs_tables "${outputs_dir}/tables"
    global outputs_logs "${outputs_dir}/logs"
    global scripts_dir "${project_root}/scripts"
    global reports_dir "${project_root}/reports"
    
    display "Project root set to: ${project_root}"
    display "Data directory: ${data_dir}"
    display "Outputs directory: ${outputs_dir}"
end

* Set up problem set specific paths
capture program drop setup_ps_paths
program define setup_ps_paths
    args ps_number
    
    if "`ps_number'" == "" {
        display as error "Error: Problem set number required"
        exit 198
    }
    
    * Set PS-specific paths
    global ps_dir "${project_root}/ps`ps_number'"
    global ps_data "${ps_dir}/ps`ps_number'_data"
    global ps_output "${ps_dir}/ps`ps_number'_output"
    global ps_papers "${ps_dir}/ps`ps_number'_papers"
    
    * Create directories if they don't exist
    capture mkdir "${ps_output}"
    
    display "PS`ps_number' directories configured:"
    display "  Data: ${ps_data}"
    display "  Output: ${ps_output}"
end

* Initialize paths (call this at the beginning of each script)
capture program drop init_paths
program define init_paths
    args ps_number
    find_project_root
    if "`ps_number'" != "" {
        setup_ps_paths `ps_number'
    }
end