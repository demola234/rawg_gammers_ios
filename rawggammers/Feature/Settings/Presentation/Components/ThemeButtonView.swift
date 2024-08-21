//
//  ThemeButtonView.swift
//  rawggammers
//
//  Created by Ademola Kolawole on 21/08/2024.
//

import SwiftUI


struct ThemeButtonSelection: View {
    var mode: Theme
    var RightBg: Color
    var RightFg: Color
    var BottomBg: Color
    var BottomFg: Color
    @EnvironmentObject var themeManager: ThemeManager
    
    
    var body: some View {
        VStack {
            VStack {
                Circle()
                    .frame(width: 20, height: 20)
                RoundedRectangle(cornerRadius: 10.0)
                    .frame(width: 50, height: 6)
                VStack {
                    RoundedRectangle(cornerRadius: 10.0)
                        .frame(width: 38, height: 6)
                    RoundedRectangle(cornerRadius: 10.0)
                        .frame(width: 38, height: 6)
                    RoundedRectangle(cornerRadius: 10.0)
                        .frame(width: 38, height: 6)
                }
                .frame(width: 55, height: 50)
                .background(RightBg, in: RoundedRectangle(cornerRadius: 8.0))
                .foregroundColor(RightFg)
            }
            .padding(10)
            .foregroundColor(BottomFg)
            .background(BottomBg, in: RoundedRectangle(cornerRadius: 15.0))
            .overlay{
                if (themeManager.currentTheme == mode) {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.theme.primaryTextColor, lineWidth: 2)
                        .padding(-3)
                }
                
                
            }
            
            Text(String(describing: mode).capitalized)
                .foregroundStyle(themeManager.currentTheme == mode ? Color.theme.textFieldColor : Color.theme.primaryTextColor)
                .customFont(CustomFont.poppinsRegualr.copyWith(size: 15))
                .frame(width: 80, height: 30, alignment: .center)
                .background(themeManager.currentTheme == mode ? Color.theme.primaryTextColor : Color.theme.cardColor, in: RoundedRectangle(cornerRadius: 10.0))
                .padding(.vertical, 10)
                
        }
    }
}


#Preview {
    ThemeButtonSelection(mode: Theme.system, RightBg: Color.theme.accentTextColor, RightFg: Color.white, BottomBg: Color.theme.accentTextColor, BottomFg: Color.white)
        .environmentObject(ThemeManager())
}