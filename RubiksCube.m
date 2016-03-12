classdef RubiksCube < handle   
    properties
        colors = struct('GREEN',1,'RED',2,'YELLOW',3,'ORANGE',4,'WHITE',5, ...
            'BLUE',6,'NONE',7);
        printColors = {'g' 'r' 'y' [1 .5 0] 'w' 'b'};
        
        turns = struct('R',1,'RINV',2,'L',3,'LINV',4, ...
            'U',5,'UINV',6,'D',7,'DINV',8, ...
            'F',9,'FINV',10,'B',11,'BINV',12, ...
            'R2',13,'L2',14,'U2',15,'D2',16,'F2',17,'B2',18);
        
        cubies = [];
    end
    
    methods
        function rc = RubiksCube
            initializeSolvedCube(rc);
        end

        function initializeSolvedCube(rc)
            rc.cubies = cell(3,3,3);
            % front face
            rc.cubies(:,1,:) = fillFaceWithColor(rc, rc.getFrontFace, 1, rc.colors.YELLOW);
            % back face
            rc.cubies(:,3,:) = fillFaceWithColor(rc, rc.getBackFace, 1, rc.colors.WHITE);
            % top face
            rc.cubies(:,:,3) = fillFaceWithColor(rc, rc.getUpFace, 2, rc.colors.BLUE);
            % bottom face
            rc.cubies(:,:,1) = fillFaceWithColor(rc, rc.getDownFace, 2, rc.colors.GREEN);
            % right face
            rc.cubies(3,:,:) = fillFaceWithColor(rc, rc.getRightFace, 3, rc.colors.ORANGE);
            % left face
            rc.cubies(1,:,:) = fillFaceWithColor(rc, rc.getLeftFace, 3, rc.colors.RED);
        end
        
        function face = getFrontFace(rc), face = rc.cubies(:,1,:); end
        function face = getBackFace(rc), face = rc.cubies(:,3,:); end
        function face = getUpFace(rc), face = rc.cubies(:,:,3); end
        function face = getDownFace(rc), face = rc.cubies(:,:,1); end
        function face = getRightFace(rc), face = rc.cubies(3,:,:); end
        function face = getLeftFace(rc), face = rc.cubies(1,:,:); end
        
        function face = fillFaceWithColor(rc, face, axis, color)
            % axis represents which face is painted where 1 is x, 2 is y,
            % and 3 is z since each cubie is represented a 1x3 vector [x y z] 
            % where the elements corresponds with the colors facing the axis
            for i = 1:numel(face)
                if isfield(face{i}, 'cubieColor')
                    face{i}.cubieColor(axis) = color;
                else
                    face{i}.cubieColor = [rc.colors.NONE rc.colors.NONE rc.colors.NONE];
                    face{i}.cubieColor(axis) = color;
                end
            end
        end
        
        function fitness = fitnessLevel(rc)
            fitness = 0;
            % bottom face is green
            bottom = rc.getDownFace();
            bottomFitness = rc.total(bottom, 2);
            fitness = fitness + bottomFitness;
            if bottomFitness ~= numel(bottom), return, end
            
            % bottom and center face is oriented
            for i = 1:2
                orientFitness = rc.orientFitness(i);
                fitness = fitness + orientFitness;
                if orientFitness ~= 12, return, end
            end
            
            % top face is blue
            top = rc.getUpFace();
            topFitness = rc.total(top, 2);
            fitness = fitness + topFitness;
            if topFitness ~= numel(top), return, end
            
            % top face is oriented
            orientFitness = rc.orientFitness(3);
            fitness = fitness + orientFitness;
            if orientFitness ~= 12, return, end
            
            % check one face to see if they line up
            front = rc.getFrontFace();
            frontFitness = rc.total(front, 1);
            if frontFitness == numel(top)
                fitness = fitness*2;
            end
        end
        
        function orFitness = orientFitness(rc, layer)
            layerFront = rc.cubies(:,1,layer);
            layerBack = rc.cubies(:,3,layer);
            layerLeft = rc.cubies(1,:,layer);
            layerRight = rc.cubies(3,:,layer);
            orFitness = rc.total(layerFront, 1) + rc.total(layerBack, 1) + ...
                rc.total(layerLeft, 3) + rc.total(layerRight, 3);
        end
        
        
        function sum = total(~, face, axis)
            colorArr = zeros(6, 1);
            for i = 1:numel(face)
                color = face{i}.cubieColor(axis);
                colorArr(color) = colorArr(color) + 1;
            end
            mostCommonColor = max(colorArr);
            if mostCommonColor > 1
                sum = mostCommonColor;
            else 
                sum = 0;
            end
        end
        
        
        function randomize(rc)
            for i = 1: 40
                randomTurn = randi(18, 1);
                rc.rotate(randomTurn);
            end
        end
        
        function rotate(rc, turnType)
            switch turnType
                case rc.turns.R
                    rc.cubies(3,:,:) = rotateCW(rc, rc.getRightFace, 3);
                case rc.turns.RINV
                    rc.cubies(3,:,:) = rotateCCW(rc, rc.getRightFace, 3);
                case rc.turns.L
                    rc.cubies(1,:,:) = rotateCCW(rc, rc.getLeftFace, 3);
                case rc.turns.LINV
                    rc.cubies(1,:,:) = rotateCW(rc, rc.getLeftFace, 3);
                case rc.turns.U
                    rc.cubies(:,:,3) = rotateCW(rc, rc.getUpFace, 2);
                case rc.turns.UINV
                    rc.cubies(:,:,3) = rotateCCW(rc, rc.getUpFace, 2);
                case rc.turns.D
                    rc.cubies(:,:,1) = rotateCCW(rc, rc.getDownFace, 2);
                case rc.turns.DINV
                    rc.cubies(:,:,1) = rotateCW(rc, rc.getDownFace, 2);
                case rc.turns.F
                    rc.cubies(:,1,:) = rotateCW(rc, rc.getFrontFace, 1);
                case rc.turns.FINV
                    rc.cubies(:,1,:) = rotateCCW(rc, rc.getFrontFace, 1);
                case rc.turns.B
                    rc.cubies(:,3,:) = rotateCCW(rc, rc.getBackFace, 1);
                case rc.turns.BINV
                    rc.cubies(:,3,:) = rotateCW(rc, rc.getBackFace, 1);
                case rc.turns.R2
                    rc.cubies(3,:,:) = rotateCW(rc, rc.getRightFace, 3);
                    rc.cubies(3,:,:) = rotateCW(rc, rc.getRightFace, 3);
                case rc.turns.L2
                    rc.cubies(1,:,:) = rotateCW(rc, rc.getLeftFace, 3);
                    rc.cubies(1,:,:) = rotateCW(rc, rc.getLeftFace, 3);
                case rc.turns.U2
                    rc.cubies(:,:,3) = rotateCW(rc, rc.getUpFace, 2);
                    rc.cubies(:,:,3) = rotateCW(rc, rc.getUpFace, 2);
                case rc.turns.D2
                    rc.cubies(:,:,1) = rotateCW(rc, rc.getDownFace, 2);
                    rc.cubies(:,:,1) = rotateCW(rc, rc.getDownFace, 2);
                case rc.turns.F2
                    rc.cubies(:,1,:) = rotateCW(rc, rc.getFrontFace, 1);
                    rc.cubies(:,1,:) = rotateCW(rc, rc.getFrontFace, 1);
                case rc.turns.B2
                    rc.cubies(:,3,:) = rotateCW(rc, rc.getBackFace, 1);
                    rc.cubies(:,3,:) = rotateCW(rc, rc.getBackFace, 1);
            end
        end
        
        function face = rotateCW(rc, face, axis)
            corners = [1 3 9 7];
            edges = [6 8 4 2];
            face = rc.rotatePiece(face, axis, corners);
            face = rc.rotatePiece(face, axis, edges);
        end
        
        function face = rotateCCW(rc, face, axis)
            corners = [7 9 3 1];
            edges = [2 4 8 6];
            face = rc.rotatePiece(face, axis, corners);
            face = rc.rotatePiece(face, axis, edges);
        end
        
        function face = rotatePiece(~, face, axis, pieceIdx)
            adjacent = [1 2 3];
            adjacent = adjacent(adjacent ~= axis);
            firstPieceColor = face{pieceIdx(1)}.cubieColor;
            currPieceColor = zeros(3, 1);
            for i = 1: (length(pieceIdx) - 1)
                nextPieceColor = face{pieceIdx(i+1)}.cubieColor;
                currPieceColor(axis) = nextPieceColor(axis);
                for j = 1:length(adjacent)
                    swapIdx = adjacent(end+1-j);
                    currPieceColor(adjacent(j)) = nextPieceColor(swapIdx);
                end
                face{pieceIdx(i)}.cubieColor = currPieceColor;
            end
            currPieceColor(axis) = firstPieceColor(axis);
            for j = 1:length(adjacent)
                swapIdx = adjacent(end+1-j);
                currPieceColor(adjacent(j)) = firstPieceColor(swapIdx);
            end
            face{pieceIdx(end)}.cubieColor = currPieceColor;
        end
        
        function plotRubiksCube(rc)
            % hard coded co ordinates of the squares to fill in with colors
            cubieCord = [0 0 0; 1 0 0; 1 0 1; 0 0 1; 0 0 0; 1 0 0; 1 1 0; 0 1 0;...
                0 0 0; 0 1 0; 0 1 1; 0 0 1; 1 0 0; 2 0 0; 2 0 1; 1 0 1; ...
                1 0 0; 2 0 0; 2 1 0; 1 1 0; 2 0 0; 3 0 0; 3 0 1; 2 0 1; ...
                2 0 0; 3 0 0; 3 1 0; 2 1 0; 3 0 0; 3 1 0; 3 1 1; 3 0 1; ...
                0 1 0; 0 2 0; 1 2 0; 1 1 0; 0 1 0; 0 2 0; 0 2 1; 0 1 1; ...
                1 1 0; 2 1 0; 2 2 0; 1 2 0; 2 1 0; 3 1 0; 3 2 0; 2 2 0; ... 
                3 1 0; 3 2 0; 3 2 1; 3 1 1; 0 3 0; 1 3 0; 1 3 1; 0 3 1; ...
                0 3 0; 1 3 0; 1 2 0; 0 2 0; 0 3 0; 0 2 0; 0 2 1; 0 3 1; ...
                1 3 0; 2 3 0; 2 3 1; 1 3 1; 1 3 0; 2 3 0; 2 2 0; 1 2 0; ...
                2 3 0; 3 3 0; 3 3 1; 2 3 1; 2 3 0; 3 3 0; 3 2 0; 2 2 0; ...
                3 2 0; 3 3 0; 3 3 1; 3 2 1; 0 0 1; 1 0 1; 1 0 2; 0 0 2; ...
                0 0 1; 0 1 1; 0 1 2; 0 0 2; 1 0 1; 2 0 1; 2 0 2; 1 0 2; ...
                2 0 1; 3 0 1; 3 0 2; 2 0 2; 3 0 1; 3 1 1; 3 1 2; 3 0 2; ...
                0 1 1; 0 2 1; 0 2 2; 0 1 2; 3 1 1; 3 2 1; 3 2 2; 3 1 2; ...
                0 3 1; 1 3 1; 1 3 2; 0 3 2; 0 2 1; 0 3 1; 0 3 2; 0 2 2; ...
                1 3 1; 2 3 1; 2 3 2; 1 3 2; 2 3 1; 3 3 1; 3 3 2; 2 3 2; ...
                3 2 1; 3 3 1; 3 3 2; 3 2 2; 0 0 2; 1 0 2; 1 0 3; 0 0 3; ...
                0 0 3; 1 0 3; 1 1 3; 0 1 3; 0 0 3; 0 1 3; 0 1 2; 0 0 2; ...
                1 0 2; 2 0 2; 2 0 3; 1 0 3; 1 0 3; 2 0 3; 2 1 3; 1 1 3; ...
                2 0 2; 3 0 2; 3 0 3; 2 0 3; 2 0 3; 3 0 3; 3 1 3; 2 1 3; ...
                3 0 2; 3 1 2; 3 1 3; 3 0 3; 0 1 3; 1 1 3; 1 2 3; 0 2 3; ...
                0 1 2; 0 2 2; 0 2 3; 0 1 3; 1 1 3; 1 2 3; 2 2 3; 2 1 3; ...
                2 1 3; 3 1 3; 3 2 3; 2 2 3; 3 1 2; 3 2 2; 3 2 3; 3 1 3; ...
                0 3 2; 1 3 2; 1 3 3; 0 3 3; 0 2 3; 1 2 3; 1 3 3; 0 3 3; ...
                0 2 2; 0 3 2; 0 3 3; 0 2 3; 1 3 2; 2 3 2; 2 3 3; 1 3 3; ...
                1 2 3; 2 2 3; 2 3 3; 1 3 3; 2 3 2; 3 3 2; 3 3 3; 2 3 3; ...
                2 2 3; 3 2 3; 3 3 3; 2 3 3; 3 3 3; 3 2 3; 3 2 2; 3 3 2;];
            cubieCordX = cubieCord(:,1); 
            cubieCordY = cubieCord(:,2); 
            cubieCordZ = cubieCord(:,3);
            idx = 1; 
            for i = 1:numel(rc.cubies)
                cubie = rc.cubies{i};
                if ~isfield(cubie, 'cubieColor'), continue, end
                cubieColor = cubie.cubieColor;
                
                for j = 1:3
                    if cubieColor(j) == rc.colors.NONE, continue, end
                    range = idx:(idx+3);
                    x = cubieCordX(range);
                    y = cubieCordY(range);
                    z = cubieCordZ(range);
                    cubieFace = patch(x,y,z, rc.printColors{cubieColor(j)});
                    set(cubieFace,'edgecolor','k', 'linewidth', 2);
                    idx = idx + 4;
                end         
            end
            
        end
    end
end

