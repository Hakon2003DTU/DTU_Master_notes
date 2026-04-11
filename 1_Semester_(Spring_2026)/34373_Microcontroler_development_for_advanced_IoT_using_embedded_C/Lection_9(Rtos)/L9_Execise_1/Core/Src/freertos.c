/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * File Name          : freertos.c
  * Description        : Code for freertos applications
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2026 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Includes ------------------------------------------------------------------*/
#include "FreeRTOS.h"
#include "task.h"
#include "main.h"
#include "cmsis_os.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
/* USER CODE BEGIN Variables */

/* USER CODE END Variables */




/* Private function prototypes -----------------------------------------------*/
/* USER CODE BEGIN FunctionPrototypes */

/* USER CODE END FunctionPrototypes */

void StartDefaultTask(void *argument);
void StartTask02(void *argument);
void StartTask03(void *argument);

void MX_FREERTOS_Init(void); /* (MISRA C 2004 rule 8.1) */

/**
  * @brief  FreeRTOS initialization
  * @param  None
  * @retval None
  */

void MX_FREERTOS_Init(void) {


  /* Create the thread(s) */
  /* creation of Blink01 */
  //Blink01Handle = osThreadNew(StartDefaultTask, NULL, &Blink01_attributes);

  /* creation of Blink02 */
  //Blink02Handle = osThreadNew(StartTask02, NULL, &Blink02_attributes);

  /* creation of Blink03 */
  //Blink03Handle = osThreadNew(StartTask03, NULL, &Blink03_attributes);
}

/*
void StartDefaultTask(void *argument)
{
  for(;;)
  {
    osDelay(1);
  }

}
*/

/*
void StartTask02(void *argument)
{
  for(;;)
  {
    osDelay(1);
  }
}
*/

/*
void StartTask03(void *argument)
{
  for(;;)
  {

    osDelay(1);
  }
} */


/* Private application code --------------------------------------------------*/
/* USER CODE BEGIN Application */

/* USER CODE END Application */

