//
//  MAPGraphViewController.swift
//  EBC Logger
//
//  Created by Zachary Massia on 2016-05-08.
//  Copyright © 2016 Zachary Massia. All rights reserved.
//

import Cocoa
import Charts

class MAPGraphViewController: NSViewController {
    @IBOutlet var lineChart: LineChartView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let xs = Array(1...10).map { return Double($0) }
        let data = LineChartData(xVals: xs)

        let ys = xs.map { i in return i * 1.12 }
        let yse = ys.enumerate().map { idx, i in return ChartDataEntry(value: i, xIndex: idx) }


        let ds = LineChartDataSet(yVals: yse, label: "PSIG")
        ds.colors = [NSUIColor.redColor()]
        data.addDataSet(ds)

        lineChart.data = data
        lineChart.gridBackgroundColor = NSUIColor.whiteColor()
        lineChart.descriptionText = "MAP Sensor Values"

        /*let yAxis = lineChart.leftAxis
        yAxis.axisMinValue = floor(ThreeBarMAP.minPSIA)
        yAxis.axisMaxValue = ceil(ThreeBarMAP.maxPSIA)
        yAxis.drawGridLinesEnabled = false
        yAxis.labelTextColor = NSColor.blackColor()
 */
    }

    override func viewWillAppear() {
        //lineChart.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
    }
}
