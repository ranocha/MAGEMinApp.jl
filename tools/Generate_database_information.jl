using MAGEMin_C


mutable struct ss_infos
    ss_name :: String
    n_em    :: Int64
    n_xeos  :: Int64
    ss_em   :: Vector{String}
    ss_xeos :: Vector{String}
end


mutable struct db_infos
    db_name :: String
    db_info :: String
    data_ss :: Array{ss_infos}
    ss_name :: Array{String}
    data_pp :: Array{String}
end


db_details      = [ "Metapelite (White et al., 2014)",
                    "Metabasite (Green et al., 2016)",
                    "Igneous HP18 (Green et al., 2023)",
                    "Igneous T21 (Green et al., 2023)",
                    "Alkaline (Weller et al., 2023)",
                    "Ultramafic (Evans & Frost., 2021)"]

database_list   = ["mp","mb","ig","igd","alk","um"]
db_inf          = Array{db_infos, 1}(undef, length(database_list))

for k=1:length(database_list)
    dtb         = database_list[k]
    gv, z_b, DB, splx_data  = init_MAGEMin(dtb; mbCpx = 0);
    sys_in      =   "mol"     #default is mol, if wt is provided conversion will be done internally (MAGEMin works on mol basis)
    test        =   0         #KLB1
    gv          =   use_predefined_bulk_rock(gv, test, dtb);
    gv.verbose  =  -1
    P           =   8.0
    T           =   800.0
    out         =   point_wise_minimization(P,T, gv, z_b, DB, splx_data, sys_in);

    ss_struct  = unsafe_wrap(Vector{LibMAGEMin.SS_ref},DB.SS_ref_db,gv.len_ss);
    ss_names   = unsafe_string.(unsafe_wrap(Vector{Ptr{Int8}}, gv.SS_list, gv.len_ss));
    pp_names   = unsafe_string.(unsafe_wrap(Vector{Ptr{Int8}}, gv.PP_list, gv.len_pp));

    ss = Array{ss_infos, 1}(undef, gv.len_ss)

    for i=1:gv.len_ss
        n_em 	= ss_struct[i].n_em
        n_xeos 	= ss_struct[i].n_xeos
        
        em_names   = unsafe_string.(unsafe_wrap(Vector{Ptr{Int8}}, ss_struct[i].EM_list, n_em))

        em_names2  = Vector{String}(undef,n_em+1)
        em_names2[1] = "none"
        em_names2[2:end] = em_names


        xeos_names = unsafe_string.(unsafe_wrap(Vector{Ptr{Int8}}, ss_struct[i].CV_list, n_xeos))
        xeos_names2  = Vector{String}(undef,n_xeos+1)
        xeos_names2[1] = "none"
        xeos_names2[2:end] = xeos_names



        ss[i]   = ss_infos(ss_names[i], n_em, n_xeos, em_names2, xeos_names2)
    end


    db_inf[k] = db_infos(database_list[k],db_details[k],ss,ss_names,pp_names)

end

print(db_inf)

# function get_property(x, name::String)
#     s = Symbol(name)
#     return getproperty(x, s)
# end