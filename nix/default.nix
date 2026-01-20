{
  stdenv,
  lib,
  python3,
  mpi,
  openblas,
  fftw,
  gsl,
  hdf5,
  tree,
  extraConfigFlags ? [
    "--cxx=g++-simd"
    "-cons_bc"
    "--coord=gr_dynamical"
    "--eos=eostaudyn_ps"
    "--eospolicy=idealgas"
    "--errorpolicy=reset_floor"
    "--flux=llftaudyn"
    "--ncghost=4"
    "--ncghost_cx=4"
    "--nextrapolate=5"
    "--nghost=4"
    "--ninterp=3"
    "--nscalars=0"
    "--prob=gr_tov"
    "-recon_cmb_hydpa"
    "-z_cx"
    "-zgf"
  ],
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gr-athena";
  version = "dev";

  src = lib.cleanSource ../.;

  patches = [
    ./git.patch
  ];

  postPatch = ''
    patchShebangs configure.py
  '';

  configureFlags = [
    "-mpi"
    "-omp"
    "-hdf5"
    "--hdf5_path=${lib.getLib hdf5}/lib"
    "-fft"
    "-gsl"
    "-openblas"
    "-rpath"
  ]
  ++ extraConfigFlags;

  configurePhase = ''
    runHook preConfigure

    ./configure.py ${lib.concatStringsSep " " finalAttrs.configureFlags}

    runHook postConfigure
  '';

  nativeBuildInputs = [
    python3
    tree
  ];

  buildInputs = [
    openblas
    fftw
    gsl
    hdf5
  ];

  propagatedBuildInputs = [ mpi ];
  propagatedUserEnvPkgs = [ mpi ];

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install bin/athena $out/bin/.

    runHook postInstall
  '';

  meta = with lib; {
    description = "General Relativistic Magneto-Hydrodynamics code based on Athena++";
    homepage = "https://github.com/computationalrelativity/gr-athena";
    license = licenses.bsd3;
  };
})
