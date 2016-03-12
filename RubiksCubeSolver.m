classdef RubiksCubeSolver
    properties
        cube = [];
        handles = [];
        population = [];
    end
    
    methods
        function rcs = RubiksCubeSolver(rubiksCube, handles)
            rcs.cube = rubiksCube;
            rcs.handles = handles;
            rcs.population = rcs.intializePopulation();
        end
        
        function [population, cube1, cube2] = simulateGeneration(rcs)
            rcs.population = rcs.selectFittest();
            cube1 = rcs.createBestSolutionCube(rcs.population{1});
            cube2 = rcs.createBestSolutionCube(rcs.population{2});
            childPopulation = rcs.breed();
            rcs.population = rcs.mergePopulation(rcs.population, childPopulation);
            mutatedPopulation = rcs.mutate();
            population = rcs.mergePopulation(rcs.population, mutatedPopulation);
        end
        
        function mergedPop = mergePopulation(~, population1, population2)
            mergedPop = cell(length(population1) + length(population2), 1);
            counter = 1;
            for i = 1:length(population1)
                mergedPop{counter} = population1{i};
                counter = counter + 1;
            end
            for i = 1:length(population2)
                mergedPop{counter} = population2{i};
                counter = counter + 1;
            end
        end
        
        function population = intializePopulation(rcs)
            population = cell(100, 1);
            population = rcs.executeRotation(population, 'initialize');
        end
        
        function cubeCopy = createBestSolutionCube(rcs, population)
            [~, idxFit] = max(population.fitnessPerMove);
            moves = population.moves(1:idxFit);
            objByteArray = getByteStreamFromArray(rcs.cube);
            cubeCopy = getArrayFromByteStream(objByteArray);
            for i = 1:length(moves)
                cubeCopy.rotate(moves(i));
            end
        end
        
        function population = executeRotation(rcs, population, command)
            fitnessPerMove = zeros(length(population), 1);
            objByteArray = getByteStreamFromArray(rcs.cube);
            intialize = strcmp(command, 'initialize');
            for i = 1:length(population)
                if intialize
                    moves = randi(18, length(population), 1);
                    population{i}.moves = moves;
                else
                    moves = population{i}.moves;
                end
                
                cubeCopy = getArrayFromByteStream(objByteArray);
                for j = 1:length(moves)
                    cubeCopy.rotate(moves(j));
                    fitnessPerMove(j) = cubeCopy.fitnessLevel();
                end
                
                population{i}.fitnessPerMove = fitnessPerMove;
            end
        end
        
        function population = mutate(rcs)
            objByteArray = getByteStreamFromArray(rcs.population);
            copyPopulation = getArrayFromByteStream(objByteArray);
            idx = randi(length(copyPopulation), 10);
            population = cell(10, 1);
            for i = 1: 10
                parent = copyPopulation{idx(i)};
                [~, idxFit] = max(parent.fitnessPerMove);
                targetIdx = randi(idxFit);
                randomRotation = randi(18);
                parent.moves(targetIdx) = randomRotation;
                population{i} = parent;
            end
        end
        
        function population = breed(rcs)
            idx = randperm(length(rcs.population));
            objByteArray = getByteStreamFromArray(rcs.population);
            randomPopulation = getArrayFromByteStream(objByteArray);
            randomPopulation = randomPopulation(idx);
            populationSize = length(rcs.population);
            population = cell(floor(populationSize/2)*2, 1);
            counter = 1;
            for i = 1: floor(populationSize/2)
                parent1 = randomPopulation{i};
                parent2 = randomPopulation{populationSize-i};
                [moves1, moves2] = rcs.crossOver(parent1.moves, parent1.fitnessPerMove, ...
                    parent2.moves, parent2.fitnessPerMove);
                parent1.moves = moves1;
                parent2.moves = moves2;
                parent1 = rcs.executeRotation({parent1}, 'none');
                parent2 = rcs.executeRotation({parent2}, 'none');
                population{counter} = parent1{1};
                population{counter+1} = parent2{1};
                counter = counter + 2;
            end
        end
        
        function [moves1, moves2] = crossOver(~, moves1, fitness1, moves2, fitness2)
            [~, idxFit1] = max(fitness1);
            [~, idxFit2] = max(fitness2);
            range = min(length(moves1), mean(idxFit1, idxFit2)+10);
            points = randi(range,1,2);
            start = min(points);
            last = max(points);
            temp = 0;
            for i = start:last
                temp = moves1(i);
                moves1(i) = moves2(i);
                moves2(i) = temp;
            end
        end
            
        function population = selectFittest(rcs)
            objByteArray = getByteStreamFromArray(rcs.population);
            copyPopulation = getArrayFromByteStream(objByteArray);
            maxFitnessPerMove = zeros(length(copyPopulation), 1);
            fitnessPerMove = cell(length(copyPopulation), 1);
            moves = cell(length(copyPopulation), 1);
            for i = 1:length(copyPopulation)
                fitnessPerMove{i} = copyPopulation{i}.fitnessPerMove;
                maxFitnessPerMove(i) = max(fitnessPerMove{i});
                moves{i} = copyPopulation{i}.moves;
            end
            
            [~, idx] = sort(maxFitnessPerMove, 'descend');
            fitnessPerMove = fitnessPerMove(idx);
            moves = moves(idx);
            for i = 1:20
                copyPopulation{i}.fitnessPerMove = fitnessPerMove{i};
                copyPopulation{i}.moves = moves{i};
            end
            randomSelected = randi(length(copyPopulation), 10, 1);
            for i = 1:10
                randomIdx = randomSelected(i);
                copyPopulation{i+20}.fitnessPerMove = fitnessPerMove{randomIdx};
                copyPopulation{i+20}.moves = moves{randomIdx};
            end
            population = copyPopulation(1:30);
        end
    end
    
end

