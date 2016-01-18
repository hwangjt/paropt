# For MPI capabilities
from mpi4py.libmpi cimport *
cimport mpi4py.MPI as MPI

# Import numpy
import numpy as np
cimport numpy as np

cdef extern from "CyParOptProblem.h":
   # Define the callback types
   ctypedef void (*getvarsandbounds)(void *_self, int nvars,
                                     double *x, double *lb, double *ub)
   ctypedef int (*evalobjcon)(void *_self, int nvars, int ncon,
                              double *x, double *fobj, double *cons)
   ctypedef int (*evalobjcongradient)(void *_self, int nvars, int ncon,
                                      double *x, double *gobj, double *A)
   ctypedef int (*evalhvecproduct)(void *_self, int nvars, int ncon, 
                                   int nwcon, double *x, double *z,
                                   double *zw, double *px, double *hvec)

   cdef cppclass CyParOptProblem:
      CyParOptProblem(MPI_Comm _comm, int _nvars, int _ncon,
                      int _nwcon, int _nwblock)

      # Set the callback functions
      void setSelfPointer(void *_self)
      void setGetVarsAndBounds(getvarsandbounds usr_func)
      void setEvalObjCon(evalobjcon usr_func)
      void setEvalObjConGradient(evalobjcongradient usr_func)
      void setEvalHvecProduct(evalhvecproduct usr_func)

      # Set options for the inequality constraints
      void setInequalityOptions(int _isSparseInequal, 
                                int _isDenseInequal,
                                int _useLower, int _useUpper)

cdef extern from "ParOptVec.h":
   cdef cppclass ParOptVec:
      ParOptVec(MPI_Comm comm, int n)
      
      # Retrieve the values from the array
      int getArray(double **array)

cdef extern from "ParOpt.h":
   cdef cppclass ParOpt:
      ParOpt(CyParOptProblem *_prob, 
             int _max_lbfgs_subspace) except +
             
      # Perform the optimiztion
      int optimize(const char *checkpoint)

      # Get the problem dimensions
      void getProblemSizes(int *nvars, int *ncon, 
                           int *nwcon, int *nwblock)

      # Retrieve the optimized point
      void getOptimizedPoint(ParOptVec **_x,
                             const double **_z, ParOptVec **_zw,
                             ParOptVec **_zl, ParOptVec **_zu)

      # Check objective and constraint gradients
      void checkGradients(double dh)
      
      # Set optimizer parameters
      void setInitStartingPoint(int init)
      void setMaxMajorIterations(int iters)
      void setAbsOptimalityTol(double tol)
      void setBarrierFraction(double frac)
      void setBarrierPower(double power)
      void setHessianResetFreq(int freq)
      void setSequentialLinearMethod(int truth)

      # Set/obtain the barrier parameter
      void setInitBarrierParameter(double mu)
      double getBarrierParameter()
      
      # Set parameters associated with the line search
      void setUseLineSearch(int truth)
      void setMaxLineSearchIters(int iters)
      void setBacktrackingLineSearch(int truth)
      void setArmijioParam(double c1)
      void setPenaltyDescentFraction(double frac)

      # Set parameters for the internal GMRES algorithm
      void setUseHvecProduct(int truth)
      void setUseQNGMRESPreCon(int truth)
      void setNKSwitchTolerance(double tol)
      void setEisenstatWalkerParameters(double gamma, double alpha)
      void setGMRESTolerances(double rtol, double atol)
      void setGMRESSubspaceSize(int _gmres_subspace_size)

      # Set other parameters
      void setOutputFrequency(int freq)
      void setMajorIterStepCheck(int step)
      void setOutputFile(const char *filename)

      # Write out the design variables to binary format (fast MPI/IO)
      int writeSolutionFile(const char *filename)
      int readSolutionFile(const char *filename)