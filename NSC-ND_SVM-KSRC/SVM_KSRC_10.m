clc;
addpath function
xlsdata = xlsread('NSC-ND.xlsx');
[~,data_len] = size(xlsdata);
opt.lambda = 0.01;
opt.tol = 1e-6;
opt.iter_num = 2000;
p = 0.1;

SvmLabel = label_all(1:10);
testrange = 1:50;   %%
testnum = 5+length(testrange)/10;
for sl = 1023
SvmFeature =  SvmLabel{sl};
disp(['SvmFeatureture No.',num2str(SvmFeature)]);

accsum = 0;
sensum = 0;
spesum = 0;

    for ten = 1:10
        [test_data,test_label,train_data,train_label] = tenfold(xlsdata([testrange,101:150],1:data_len-1),xlsdata([testrange,101:150],data_len));  %%

    label = zeros(testnum,10);

    rightnums = 0;
    SRCrun = 0;
    SVMrun = 0;
    for j = 1:10
         traindata = train_data{j};
         testdata = test_data{j};

         trainsvm = traindata(:,SvmFeature); 
         testsvm = testdata(:,SvmFeature);

         SVMModel = fitcsvm(trainsvm,train_label{1},'Standardize',true,'KernelFunction','linear');  
         supportvector = [trainsvm(SVMModel.IsSupportVector,1),trainsvm(SVMModel.IsSupportVector,2),...
             trainsvm(SVMModel.IsSupportVector,3),trainsvm(SVMModel.IsSupportVector,4),...
             trainsvm(SVMModel.IsSupportVector,5),trainsvm(SVMModel.IsSupportVector,6),...
             trainsvm(SVMModel.IsSupportVector,7),trainsvm(SVMModel.IsSupportVector,8),...
             trainsvm(SVMModel.IsSupportVector,9),trainsvm(SVMModel.IsSupportVector,10)];
         supportarea1 = ScatterHull(supportvector(:,1:2),180);
         supportarea2 = ScatterHull(supportvector(:,2:3),180);
         supportarea3 = ScatterHull(supportvector(:,3:4),180);
         supportarea4 = ScatterHull(supportvector(:,4:5),180);
         supportarea5 = ScatterHull(supportvector(:,5:6),180);
         supportarea6 = ScatterHull(supportvector(:,6:7),180);
         supportarea7 = ScatterHull(supportvector(:,7:8),180);
         supportarea8 = ScatterHull(supportvector(:,8:9),180);
         supportarea9 = ScatterHull(supportvector(:,9:10),180);
         [in1,on1] = inpolygon(testsvm(:,1),testsvm(:,2),supportarea1(:,1),supportarea1(:,2));
         [in2,on2] = inpolygon(testsvm(:,2),testsvm(:,3),supportarea2(:,1),supportarea2(:,2));
         [in3,on3] = inpolygon(testsvm(:,3),testsvm(:,4),supportarea3(:,1),supportarea3(:,2));
         [in4,on4] = inpolygon(testsvm(:,4),testsvm(:,5),supportarea4(:,1),supportarea4(:,2));
         [in5,on5] = inpolygon(testsvm(:,5),testsvm(:,6),supportarea5(:,1),supportarea5(:,2));
         [in6,on6] = inpolygon(testsvm(:,6),testsvm(:,7),supportarea6(:,1),supportarea6(:,2));
         [in7,on7] = inpolygon(testsvm(:,7),testsvm(:,8),supportarea7(:,1),supportarea7(:,2));
         [in8,on8] = inpolygon(testsvm(:,8),testsvm(:,9),supportarea8(:,1),supportarea8(:,2));
         [in9,on9] = inpolygon(testsvm(:,9),testsvm(:,10),supportarea9(:,1),supportarea9(:,2));
         in = (in1&in2)&(in3&in4)&(in5&in6)&in7&in8&in9;
         on = (on1&on2)&(on3&on4)&(on5&on6)&on7&on8&on9;

         A = traindata(:,11:data_len-1)';
         testSC = testdata(:,11:data_len-1)';
         KAA = Gsker(A,A,p); 
         for i = 1:testnum

             if in(i) == 1 || on(i) == 1    
                SRCrun = SRCrun + 1;   
                y = testSC(:,i);
                 KAy = Gsker(A,y,p); 
                [beta,~] = KernelCoorDescent(KAA,KAy,opt);
                beta1 = [beta(1:(9*testnum-45));zeros(45,1)];  
                       beta2 = [zeros((9*testnum-45),1);beta((9*testnum-44):9*testnum)]; 
                err1 = y - A*beta1;
                err2 = y - A*beta2;
                err = [err1'*err1,err2'*err2];
                if err(1) == err(2)
                    continue;
                end
                label(i,j) = find(err==min(err)) - 1;           
            else  
                SVMrun = SVMrun + 1;
                [predict_label_s,scores_s] = predict(SVMModel, testsvm(i,:));
                label(i,j) = predict_label_s;
            end
         end
    end
    TP = length(find(label(testnum-4:testnum,1:10)==1));
    FP = length(find(label(1:testnum-5,1:10)==1));
    TN = length(find(label(1:testnum-5,1:10)==0));
    FN = length(find(label(testnum-4:testnum,1:10)==0));

    rightnum = TP + TN; 
    acc = 100*rightnum/(testnum*10);
    sen = 100*TP/(TP+FN);
    spe = 100*TN/(TN+FP);
    disp(['acc=',num2str(acc),'%,','sen=',num2str(sen),'%,','spe=',num2str(spe),'%']);
    accsum = accsum + acc;
    sensum = sensum + sen;
    spesum = spesum + spe;


    end
    disp(['Average��acc=',num2str(accsum/10),'%,','sen=',num2str(sensum/10),'%,','spe=',num2str(spesum/10),'%']);

end


