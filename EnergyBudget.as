package code {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;

  public class EnergyBudget extends EnergyGraphBase {

    // 190.20x186.90
    private const MASK_Y1_BASE_RATIO:Number = 0.14;
		private const MASK_Y4_BASE_RATIO:Number = 0.4;
		private const MASK_X5_RATIO:Number = 0.37;
		private const MAX_BUDGET_WIDTH:Number = 190.20;
		private const BUDGET_HEIGHT_RATIO:Number = 0.58;
		private const MAX_BUDGET_HEIGHT:Number = 187;

    private var data:EnergyData;
		private var xBase:Number;
		private var yBase:Number;
		private var budgetRedMC:MovieClip;
		private var budgetGreenMC:MovieClip;
		private var budgetEmptyMC:MovieClip;
		private var budgetMask:Shape;
		private var budgetHeight:Number;
		private var budgetWidth:Number;
		private var xPos:Number;
		private var maxBudgetLimitInAllYears:Number;

    public function EnergyBudget(data:EnergyData,
																 xBase:Number,
																 yBase:Number) {
			super(EnergyConsts.BUDGET_NAME);
			this.data = data;
			this.xBase = xBase;
			this.yBase = yBase - TITLE_HEIGHT;
			maxBudgetLimitInAllYears = data.getMaxBudgetLimitInAllYears();

			addEventListener(Event.ADDED, setupChildren, false, 0, true);
    }

    private function setupChildren(e:Event):void {
			removeEventListener(Event.ADDED, setupChildren);
			
			updateUsage(true);
    }
		
		public function updateUsage(limitChanged:Boolean):void {
			super.clearContainer();
			super.container = new Sprite();
			if (limitChanged) {
				createBudget();
			}
			var price:Number = this.data.currentDataItem.totalPrice;
			var limit:Number = this.data.currentDataItem.budgetLimit;
			super.sourceValueTF.text = String(Math.round(price));
			if (price > limit) {
				super.container.addChild(budgetRedMC);
			}
			else if (price == limit) {
				budgetGreenMC.mask = null;
				super.container.addChild(budgetGreenMC);
			}
			else {
				var budgetH:Number = budgetHeight * BUDGET_HEIGHT_RATIO * price / limit;
				budgetGreenMC.mask = null;
				super.container.addChild(budgetEmptyMC);
				// it has to be added after budgetEmptyMC;
				super.container.addChild(budgetGreenMC);
				budgetMask = new Shape();
        var maskCmds:Vector.<int> = new Vector.<int>();
        maskCmds.push(1, 2, 2, 2, 2, 2);
        var maskCoord:Vector.<Number> = new Vector.<Number>();
				var xL:Number = xPos - 1;
				var xR:Number = xPos + budgetWidth + 1;
				var yB:Number = yBase + 1;
				var y1:Number = yBase - MASK_Y1_BASE_RATIO * budgetHeight - budgetH;
        maskCoord.push(xL, y1,
											 xL, yB,
											 xR, yB,
											 xR, yBase - MASK_Y4_BASE_RATIO * budgetHeight - budgetH,
											 xPos + budgetWidth * MASK_X5_RATIO, yBase - budgetH,
											 xL, y1);
				budgetMask.graphics.beginFill(0x000000);
        budgetMask.graphics.drawPath(maskCmds, maskCoord);
				budgetMask.graphics.endFill();
				super.container.addChild(budgetMask);
			  budgetGreenMC.mask = budgetMask;
			}
			addChild(super.container);
		}
		
		private function createBudget():void {
			var ratio:Number = data.currentDataItem.budgetLimit / maxBudgetLimitInAllYears;
			var uiR:Number = Math.sqrt(ratio);
			budgetHeight = Math.round(MAX_BUDGET_HEIGHT * uiR);
			var mtx:Matrix = new Matrix(uiR, 0, 0, uiR);
			
      // added in the updateUsage(), as needed;
		  budgetRedMC = new BudgetRed2MC();
			budgetRedMC.transform.matrix = mtx;
			var yPos:Number = yBase - budgetRedMC.height;
			budgetWidth = budgetRedMC.width;
			xPos = xBase + (1 - uiR) * MAX_BUDGET_WIDTH * MASK_X5_RATIO;
			budgetRedMC.x = xPos;
			budgetRedMC.y = yPos;
			
			budgetGreenMC = new BudgetGreen2MC();
			budgetGreenMC.transform.matrix = mtx;
			budgetGreenMC.x = xPos;
			budgetGreenMC.y = yPos;
			
			budgetEmptyMC = new BudgetEmpty2MC();
			budgetEmptyMC.transform.matrix = mtx;
			budgetEmptyMC.x = xPos;
			budgetEmptyMC.y = yPos;
			
			super.setupTitle(xPos, yBase, budgetRedMC.width);
			super.setupSourceValueField(xPos, yPos - TITLE_HEIGHT, budgetRedMC.width);
		}

  }
}
