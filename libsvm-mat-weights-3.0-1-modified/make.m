function make
% This make.m is used under Windows
arch = computer('arch');
% add -largeArrayDims on 64-bit machines
switch arch
    case {'win64'}
        mex -largeArrayDims -O -c utility.cpp
        mex -largeArrayDims -O -c svm.cpp
        mex -largeArrayDims -O -c svm_model_matlab.cpp
        mex -largeArrayDims -O -output svmtrain2 svmtrain.cpp svm.obj svm_model_matlab.obj
        mex -largeArrayDims -O svmpredict.cpp svm.obj svm_model_matlab.obj
        mex -largeArrayDims -O libsvmread.cpp
        mex -largeArrayDims -O libsvmwrite.cpp
    case {'glnxa64'}
        mex -largeArrayDims -O -c utility.cpp
        mex -largeArrayDims -O -c svm.cpp
        mex -largeArrayDims -O -c svm_model_matlab.cpp
        mex -largeArrayDims -O -output svmtrain2 svmtrain.cpp svm.o svm_model_matlab.o
        mex -largeArrayDims -O svmpredict.cpp svm.o svm_model_matlab.o
        mex -largeArrayDims -O libsvmread.cpp
        mex -largeArrayDims -O libsvmwrite.cpp
    case {'win32'}
        mex -O -c utility.cpp
        mex -O -c svm.cpp
        mex -O -c svm_model_matlab.cpp
        mex -O -output svmtrain2 svmtrain.cpp svm.obj svm_model_matlab.obj
        mex -O svmpredict.cpp svm.obj svm_model_matlab.obj
        mex -O libsvmread.cpp
        mex -O libsvmwrite.cpp
    case {'glnxa32'}
        mex  -O -c utility.cpp
        mex  -O -c svm.cpp
        mex  -O -c svm_model_matlab.cpp
        mex  -O -output svmtrain2 svmtrain.cpp svm.o svm_model_matlab.o
        mex  -O svmpredict.cpp svm.o svm_model_matlab.o
        mex  -O libsvmread.cpp
        mex  -O libsvmwrite.cpp
    otherwise
        error('Unkown computer arch: %s', arch);
end
