<?php
    $error = array(
              'code' => $exception->getCode(),
              'message' => $exception->getMessage()
             );

    if (CONST_Debug) {
        $error['details'] = $exception->getFile() . '('. $exception->getLine() . ')';
    }

    javascript_renderData(array('error' => $error));
