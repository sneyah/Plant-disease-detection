function varargout = model(varargin)
% MODEL MATLAB code for model.fig
%      MODEL, by itself, creates a new MODEL or raises the existing
%      singleton*.
%
%      H = MODEL returns the handle to a new MODEL or the handle to
%      the existing singleton*.
%
%      MODEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MODEL.M with the given input arguments.
%
%      MODEL('Property','Value',...) creates a new MODEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before model_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to model_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 31-Mar-2024 12:24:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @model_OpeningFcn, ...
                   'gui_OutputFcn',  @model_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before model is made visible.
function model_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to model (see VARARGIN)

% Choose default command line output for model
handles.output = hObject;

% Create a text box for displaying the predicted disease
handles.text_disease = uicontrol('Style', 'text', ...
    'Units', 'normalized', ...
    'Position', [0.1, 0.1, 0.8, 0.05], ...
    'String', 'Predicted Disease:', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 12);

% Load the trained network
load('C:\Users\USER\Desktop\trained models\resnetAdam.mat');

% Check if the loaded variable is a DAGNetwork object
if isa(trainedNetwork_1, 'DAGNetwork')
    disp('Trained network loaded successfully.');
else
    error('The loaded variable is not a DAGNetwork object.');
end

% Store the trained network in handles for accessibility
handles.trainedNetwork = trainedNetwork_1;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = model_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open file dialog for image selection
[fileName, filePath] = uigetfile({'*.jpg;*.jpeg;*.png','Image Files (*.jpg,*.jpeg,*.png)';'*.*','All Files'},'Select Image File');

% Check if user canceled the operation
if isequal(fileName,0)
    disp('User selected Cancel');
    return;
end

% Read the selected image
imageData = imread(fullfile(filePath, fileName));

% Do something with the uploaded image, for example display it
axes(handles.axes1); % Assuming axes1 is the handle to the axes where you want to display the image
imshow(imageData);

% Store uploaded image data in handles structure
handles.imageData = imageData;
guidata(hObject, handles); % Update handles structure

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check if an image has been uploaded
if ~isfield(handles, 'imageData') || isempty(handles.imageData)
    errordlg('Please upload an image first.', 'Error');
    return;
end

% Preprocess the image if necessary
% (Resize the image to match the expected input size of the neural network)
preprocessedImage = imresize(handles.imageData, [224 224]);

% Use the trained model to predict
prediction = predict(handles.trainedNetwork, preprocessedImage);

% Assuming you have a cell array of class names called 'classNames'
classNames = {'Black Rot', 'Esca', 'Healthy', 'Leaf Blight'};

% Get the index of the maximum probability
[~, maxIndex] = max(prediction);

% Get the corresponding disease name
predictedDisease = classNames{maxIndex};

% Display the prediction result
disp('Predicted Disease:');
disp(predictedDisease);

% Update the text box with the predicted disease name
set(handles.text_disease, 'String', ['Predicted Disease: ', predictedDisease]);

% Optionally, perform further actions based on the prediction
% For example, update UI elements or display a message
msgbox(sprintf('The predicted disease is: %s', predictedDisease), 'Prediction Result');

% Clear uploaded image data
handles = rmfield(handles, 'imageData');
guidata(hObject, handles); % Update handles structure
